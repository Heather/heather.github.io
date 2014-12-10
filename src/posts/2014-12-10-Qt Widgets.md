---
title: Modern C++ and Qt Widgets (basics)
---

I never liked and I still don't like Qt but maybe I will need it in near future. <br/>
Here is my fast review.

PATH
----

GUI application that extracts PATH windows variable and gives you easy way to edit it. <br/>
For now it just splits by `;` PATH into different edits with possibility to edit / delete those edits or add new edits. <br/>
And finally concatenates them all to one string with `;` separator.

``` cpp
Path::Path() {
    path = std::getenv("PATH");
}

std::vector<std::string> Path::GetPath() {
    std::vector<std::string> strs;
    boost::split(strs, path, boost::is_any_of(";"));
    return strs;
}

void Path::Reload() {
    path = std::getenv("PATH");
}
```

GUI header
----------

``` cpp
class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_actionReload_triggered();
    void on_actionDisplay_triggered();
    void on_actionVersion_triggered();

private:
    void DrawPath();

    std::unique_ptr<Ui::MainWindow> ui;
    std::unique_ptr<Path> path;
};
```

For me it looks sane to use `unique_ptr` here but for Qt Creator it's often a problem.

GUI methods
-----------

``` cpp
void MainWindow::DrawPath() {
    for (std::string str : path->GetPath()) {
        auto editForm = new QLineEdit();
        auto btnDelete = new QPushButton("Del");
        connect(btnDelete, &QPushButton::clicked, [editForm, btnDelete] () {
             if (editForm) delete editForm;
             if (btnDelete) delete btnDelete;
        });
        QString qstr = QString::fromUtf8(str.c_str());
        editForm->setText(qstr);
        this->ui->formLayout->addRow(btnDelete, editForm);
    }
    auto editAdd = new QLineEdit();
    auto btnAdd = new QPushButton("Add");
    connect(btnAdd, &QPushButton::clicked, [btnAdd, editAdd, this] () {
        auto editForm2 = new QLineEdit(editAdd->text());
        auto btnDelete2 = new QPushButton("Del");
        connect(btnDelete2, &QPushButton::clicked, [editForm2, btnDelete2] () {
             if (editForm2) delete editForm2;
             if (btnDelete2) delete btnDelete2;
        });
        this->ui->formLayout->insertRow(this->ui->formLayout->rowCount() - 1
                                       , btnDelete2, editForm2);
        editAdd->setText("");
    });
    this->ui->formLayout->addRow(btnAdd, editAdd);
}

void MainWindow::on_actionReload_triggered() {
    path->Reload();
    while (QLayoutItem* item = this->ui->formLayout->takeAt(0)) {
        if (QWidget* widget = item->widget())
            delete widget;
    }
    this->DrawPath();
}

void MainWindow::on_actionDisplay_triggered() {
    QString con;
    for (QLineEdit* qle : this->findChildren<QLineEdit *>()) {
        con += qle->text() + ";";
    }
    auto window = new QDialog(this);
    auto layout = new QVBoxLayout();
    auto btn_Ok = new QPushButton("Ok");
    layout->addWidget(new QTextEdit(con));
    layout->addWidget(btn_Ok);
    connect(btn_Ok, &QPushButton::clicked, [window] () {
         if (window) window->close();
    });
    window->setLayout(layout);
    window->setAttribute(Qt::WA_DeleteOnClose);
    window->show();
}
```

Maybe there are some weak moments alike:
 - `for (QLineEdit* qle : this->findChildren<QLineEdit *>())` as `formLayout` strings iteration
 - `setText` needs `QString` and not just std string with some reason

There is no much to review so far, I plan to check more about what Qt Widgets can do and how I can work with OpenCL there.

GitHub: [PATH](https://github.com/Heather/PATH)

