# eclm
A repository meant to demonstrate the ERR_CONTENT_LENGTH_MISMATCH error on FreeBSD

To reproduce the error you will have to a recent FreeBSD installation
(I use FreeBSD 10) and do the following to get the server running:

    > git clone ...
    > gmake
    > ./run
    
The code uses the hostname 'eclm' so you'll either have to change the
code to use something else (like localhost) or add the name 'eclm' to your hosts file.

Once you have the hostname correct you can then open up your browser's
development tools, monitor the network and load the page
eclm/test.html.

Please note that the error does not show up immediately since the
browser is waiting for more data from the server. After about 5-6
seconds the browser gives up and reports that the content length in
the header does not match what it received from the server.

This setup assumes you have the OS socket send buffer set to 32KB. To
make sure it's that way run the following command as root:

    # sysctl net.inet.tcp.sendspace

To change it you can do the following:

    # sysctl net.inet.tcp.sendspace=32768
