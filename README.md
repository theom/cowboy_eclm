# eclm

A repository meant to demonstrate the ERR_CONTENT_LENGTH_MISMATCH
error in a browser when Cowboy runs on FreeBSD and the browser tries
to receive a file larger than 32KB (or more specifically, a file
larger than the OS send buffer).

To reproduce the error you should use a recent FreeBSD installation
(I use FreeBSD 10) and do the following to get the server running:

    > git clone ...
    > cd eclm
    > gmake
    > ./run
    
The code uses the hostname 'eclm' so you'll either have to change the
code to use something else (like localhost) or add the name 'eclm' to
your hosts file.

Once you have the hostname correct you can open up your browser's
development tools, click the network tab and load the page
http://eclm:1400/test.html (replace eclm with localhost if you changed
the source). The load should fail just short of the last few tens of
bytes in the file.

Please note that the error does not show up immediately since the
browser is waiting for more data from the server. After about 5-6
seconds the browser gives up and reports that the content length in
the header does not match what it received from the server.

This setup assumes you have the OS socket send buffer set to 32KB. To
make sure it's that way you can run the following command as root:

    # sysctl net.inet.tcp.sendspace

To change it you can run:

    # sysctl net.inet.tcp.sendspace=32768

## A TCP server and a slow client

To test this a bit further I created a simple TCP server that, once a
client connects, sends a large stream of bytes to the client and then
immediately closes the connection. The client is deliberately slow to
make sure the server has closed the connection before the client
finishes receiving the data.

To test this I did the following:

In one terminal:

    > cd src
    > erl
    erl> c(tcp_server).
    erl> tcp_server:start().

Then in another terminal:

    > cd src
    > erl
    erl> c(tcp_client).
    erl> tcp_client:start().

The result is that the client always receives all the data, both for
small (a few bytes) and large (MB) data sets, which is contradictory
to what the browser experiences when receiving data from Cowboy where
the buffer overflow is missing.

This probably doesn't accurately simulating the way Cowboy sends data
but this at least gives us a hint that socket sends in Erlang on
FreeBSD is not completely broken :).
