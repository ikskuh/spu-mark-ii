#ifndef MAINWINDOW_HPP
#define MAINWINDOW_HPP

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_actionQuit_triggered();

    void on_actionSave_Memory_triggered();

    void on_actionLoad_Memory_triggered();

    void on_actionWebsite_triggered();

    void on_actionAbout_triggered();

    void on_actionAbout_Qt_triggered();

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_HPP
