### About

A script to automate the SSL/TLS certificate generation process using [LetsEncrypt](https://letsencrypt.org/) and [Docker](https://docs.docker.com/install/).


### Requirements

* [Docker](https://docs.docker.com/v17.12/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)

### How to use

Run `get_ssl_cert.sh` script with the following options:

    # Modes
    --test   # runs certbot in staging mode.
             # useful to test if your domain works.
    --info   # get additional information about certificates for your domain.
    --prod   # request certificate.
    
    # Certbot options
    -d       # domain name.
             # you can pass as many as you want (see example).
             # note that all domains you pass here will share the same SSL/TLS certificate.
             # only use in 'prod' or 'test' mode.
    --email  # an email address to be supplied to LetsEncrypt.
             # this is useful if you want to LetsEncrypt to send you expiry notifications.
             # only use in 'prod' mode.
    
For example:

    bash get_ssl_cert.sh --prod -d "mysite.com" -d "www.mysite.com" --email "myemail@email.com"

will create a folder `ssl` in the current directory with an ssl certificate and ssl certificate key.
A [Diffie Hellman parameters](https://wiki.openssl.org/index.php/Diffie-Hellman_parameters) file
will also be created. You can then use those files in your Nginx configuration file:

    server {
        ...
        
        server_name           www.mysite.com
        
        ...
        
        ssl_certificate       PATH/TO/letsencrypt/ssl/live/mysite.com/fullchain.pem
        ssl_certificate_key   PATH/TO/letsencrypt/ssl/live/mysite.com/privkey.pem
        
        ...
        
        ssl_dh_param          PATH/TO/letsencrypt/ssl/dhparam-2048.pem
        
        ...
    }