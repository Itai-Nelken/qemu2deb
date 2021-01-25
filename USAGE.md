# Detailed usage instructions:
1) create a working directory, inside this directory the deb will be created and if needed QEMU compiled. example: `/home/$USER/Documents/debpkg/`

2) download and run the script using the instructions in the [README](https://github.com/Itai-Nelken/qemu2deb-RPi#usage).

3) when you get to this screen:<br>
![qemu2deb-usage1.png](screenshots/usage/qemu2deb-usage1.png)<br>
enter the path to the file you created in step 1.

4) when you get to the following screen:<br>
![qemu2deb-usage2.png](screenshots/usage/qemu2deb-usage2.png)<br>
enter the path to your already compiled and installed QEMU folder or if you didn't compile QEMU press s.

5) when you get to this screen:<br>
![qemu2deb-usage3.png](screenshots/usage/qemu2deb-usage3.png)<br>
press ENTER if the data is correct or CTRL+C to cancel.

6)when you get to this screen:<br>
![qemu2deb-usage4.png](screenshots/usage/qemu2deb-usage4.png)<br>
press ENTER to continue.

7) now the script will copy all the files from the installation on your system to a temporary folder that later will be packaged to a deb.<br>
![qemu2deb-usage5.png](screenshots/usage/qemu2deb-usage5.png)<br>

8) when you get to this screen:<br>
![qemu2deb-usage6.png](screenshots/usage/qemu2deb-usage6.png)<br>
enter your maintainer details: name, email address, link etc.
I put `Itai Nelken - https://github.com/Itai-Nelken/`

9) now the script will use `dpkg-deb` to build the deb.<br>
![qemu2deb-usage7.png](screenshots/usage/qemu2deb-usage7.png)<br>
this will use all cpu and alot of memory (RAM).

10) now the script will tell you the path to the deb and its name
![qemu2deb-usage8.png](screenshots/usage/qemu2deb-usage8.png)<br>
press ENTER to continue.

11) now the script will ask you if you want to install the DEB,
![qemu2deb-usage9.png](screenshots/usage/qemu2deb-usage9.png)<br>
answer whatever you want, if you answer yes, you might see a few errors. that is won't affect anything and I'm trying to fix it.

12) now the script will start cleaning up after itself, answer whatever you want.
![qemu2deb-usage10.png](screenshots/usage/qemu2deb-usage10.png)<br>
![qemu2deb-usage11.png](screenshots/usage/qemu2deb-usage11.png)<br>
![qemu2deb-usage12.png](screenshots/usage/qemu2deb-usage12.png)<br>
the finished deb:
![qemu2deb-usage13.png](screenshots/usage/qemu2deb-usage13.png)<br>
