---
title: Boost Log to Elasticsearch
---

Elasticsearch
=============

[Elasticsearch](https://www.elastic.co/) is search engine. It's opensource and used by ebay, stackoverflow, etc...
I've used their 2.x branch because 3.x (master) version has incompatibility issues with their Visualization portal (Kibana)
And there is logging there is very simple but with good plugins architecture logging service [Logstash](https://www.elastic.co/products/logstash)
which has out-from-box integration with Elasticsearch. Very simple Logstash config status may look like this:

``` json
input {
    tcp {
        port => 666
    }
}
output {
    elasticsearch {
        protocol => "http"
    }
}
```

[Kibana](https://www.elastic.co/products/kibana) setup is either pretty easy and needs no additional configuration

Logging
=======

I'm using global logging I will have access from any part of my application, but it's optional. Sure, with boost.

``` cpp
BOOST_LOG_INLINE_GLOBAL_LOGGER_DEFAULT(x_logger,
    boost::log::sources::severity_logger< boost::log::trivial::severity_level >)
```

So I need to log into tcp server with six-six-six port. Well but as interface allows me to do it I will also make local logs
Remote server is very good when we need to make some data work there but if we will have no connection having logs locally will be helpful.

``` cpp
/// define helper types for log sinks
typedef boost::log::sinks::asynchronous_sink< boost::log::sinks::text_file_backend > file_sink;
typedef boost::log::sinks::asynchronous_sink< boost::log::sinks::text_ostream_backend > tcp_sink;

/// initialize and start loggers
void init() {
    /// get global logger
    src::severity_logger< boost::log::trivial::severity_level > lg = x_logger::get();

    /// init sinks
    boost::shared_ptr< file_sink > sink1(new file_sink(
        keywords::file_name = "%Y%m%d_%H%M%S_%5N.xml",
        keywords::rotation_size = 16384
        ));
    boost::shared_ptr< tcp_sink > sink2(new tcp_sink(backend));

    /// init tcp stream
    boost::shared_ptr< sinks::text_ostream_backend > backend =
        boost::make_shared< sinks::text_ostream_backend >();
    boost::shared_ptr< boost::asio::ip::tcp::iostream > stream =
        boost::make_shared< boost::asio::ip::tcp::iostream >();
    stream->connect("127.0.0.1", "666");
    backend->add_stream(stream);
    backend->auto_flush(true);

    /// set xml format for file logger
    sink->locked_backend()->set_file_collector(sinks::file::make_collector(
        keywords::target = path,                        /*< the target directory >*/
        keywords::max_size = 64 * 1024 * 1024,          /*< maximum total size of the stored files, in bytes >*/
        keywords::min_free_space = 100 * 1024 * 1024    /*< minimum free space on the drive, in bytes >*/
    ));
    sink->set_formatter (
        expr::format("\t<record id=\"%1%\" timestamp=\"%2%\">%3%</record>")
        % expr::attr< unsigned int >("RecordID")
        % expr::attr< boost::posix_time::ptime >("TimeStamp")
        % expr::xml_decor[expr::stream << expr::smessage]
    );
    auto write_header = [](sinks::text_file_backend::stream_type& file) {
        file << "<?xml version=\"1.0\"?>\n<log>\n";
    };
    auto write_footer = [](sinks::text_file_backend::stream_type& file) {
        file << "</log>\n";
    };
    /// Set header and footer writing functors
    sink->locked_backend()->set_open_handler(write_header);
    sink->locked_backend()->set_close_handler(write_footer);
    /// Add the sink to the core
    logging::core::get()->add_sink(sink);
    logging::core::get()->add_sink(sink2);
    logging::core::get()->add_global_attribute("TimeStamp", attrs::local_clock());
    logging::core::get()->add_global_attribute("RecordID", attrs::counter< unsigned int >());
    logging::add_common_attributes();

    BOOST_LOG_SEV(lg, boost::log::trivial::trace) << "Loggers initialization complete";
}
```

To simplify calling `BOOST_LOG_SEV` from any part application there could be macros alike

``` cpp
#define X_INFO BOOST_LOG_STREAM_SEV(x_logger::get(), boost::log::trivial::info)
#define X_ERROR BOOST_LOG_STREAM_SEV(x_logger::get(), boost::log::trivial::error)
...
```

It will log either into Elasticsearch and into some path creating xmls for each application run

P.S.
====

Additional thanks to Chris Allen for [bloodhound](https://github.com/bitemyapp/bloodhound) for making it easy to have Haskell clients to those logs :P
