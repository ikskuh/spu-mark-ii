#include "mainwindow.hpp"
#include "ui_mainwindow.h"

#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::on_actionQuit_triggered()
{
    this->close();
}

void MainWindow::on_actionSave_Memory_triggered()
{

}

void MainWindow::on_actionLoad_Memory_triggered()
{

}

void MainWindow::on_actionWebsite_triggered()
{

}

void MainWindow::on_actionAbout_triggered()
{
    QMessageBox::about(this,
                       tr("Ashet Home Computer"),
                       tr("This is the official emulator for the Ashet Home Computer"));
}

void MainWindow::on_actionAbout_Qt_triggered()
{
    QMessageBox::aboutQt(this);
}
