---
title: Python SmartShell
---

Task: save modified Environment variable during calling different scripts in python
Solution: Singleton with internal variable for storing and updating Environment

SmartShell
----------

``` python
from subprocess import Popen, PIPE, list2cmdline
from Singleton import Singleton

class SmartShell(Singleton):
    def __init__(self, shell):
        self.shell = shell
        self.initial = None
    def validate(self, ob): return (len(ob) == 2)
    def env_cmd(self, env_cmd):
        env_cmd         = list2cmdline(env_cmd)
        cmd             = 'cmd.exe /s /c "{env_cmd} && set"'.format(**vars())
        proc            = Popen(cmd
                            , stdout    = PIPE
                            , shell     = self.shell
                            , env       = self.initial)
        lines           = proc.stdout
        handle_line     = lambda l: l.rstrip().split('=',1)
        pairs           = map(handle_line, lines)
        valid_pairs     = filter(self.validate, pairs)
        self.initial    = dict(valid_pairs)
        proc.communicate()
    def command(self, just_cmd):
        just_cmd    = list2cmdline(just_cmd)
        cmd         = 'cmd.exe /s /c "{just_cmd}"'.format(**vars())
        proc        = Popen(cmd
                            , stdout    = PIPE
                            , shell     = self.shell
                            , env       = self.initial)
        lines       = proc.stdout.readlines()
        proc.communicate()[0]
        return lines
    def cmd(self, s): print("".join(self.command(s)))
    def run(self, s): print("".join(self.command(s.split(' '))))
```

There are various implementations of Singleton object in python so here is example

``` python
class Singleton(object):
    _instances = {}
    def __new__(class_, *args, **kwargs):
        if class_ not in class_._instances:
            class_._instances[class_] = super(Singleton, class_).__new__(class_, *args, **kwargs)
        return class_._instances[class_]

```

Usage
-----------

``` python
from lib import SmartShell
shell = SmartShell(True)
#To store modified Environment variables
e.env_cmd([LoadMSBuild, Options])
#To use internal class Environment
e.run("MSBuild /version")
```

Idea came from this [StackOverflow answer](http://stackoverflow.com/a/2214292/238232)
