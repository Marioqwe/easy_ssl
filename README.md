## About

A script to automate the SSL/TLS certificate generation process using [LetsEncrypt](https://letsencrypt.org/) and [Docker](https://docs.docker.com/install/).


### Requirements

* [Docker](https://docs.docker.com/v17.12/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)

### How to use

Run `get_ssl_cert.sh` script with the following options:

    # Modes
    --info        # get additional information about certificates for your domain.
    --prod        # request certificate.
    --renew       # renew certificate for your domain.
    --revoke      # revoke certificate.
                  # note that if you are revoking a certificate that was generated using
                  # "test" mode, you will need to pass the "--staging" option as well.
    --test        # runs certbot in staging mode.
                  # useful to test if your domain works.
               
    # Options
    -d            # domain name.
                  # you can pass as many as you want (see example).
                  # note that all domains you pass here will share the same SSL/TLS certificate.
                  # if used in "info" or "renew" mode, this option is ignored.
                  # if used in "revoke" mode, the certificate associated with the domain will be
                  # revoked.
    --dev-server  # by default false.
                  # use together with "renew" mode, ignored otherwise.
                  # use this flag to indicate whether you want to spin up an nginx container
                  # to renew your certificate.
    --email       # an email address to be supplied to LetsEncrypt.
                  # this is useful if you want to LetsEncrypt to send you expiry notifications.
                  # only use in 'prod' mode.
    --out-dir     # by default "~/easy_ssl/ssl".
                  # if used in "test", or "prod" mode, the directory will contain all
                  # output from certbot, including certificates.
                  # if used in "renew", "info", or "revoke" mode, the value should point to the
                  # directory generated in either "test" or "prod" mode.
    --skip-dh     # if used, diffie helman parameters file won't be generated.
    
For example:

    bash get_ssl_cert.sh --prod -d "mysite.com" -d "www.mysite.com" --email "myemail@email.com"

will create a folder `ssl` in the current directory with an ssl certificate and ssl certificate key.
A [Diffie Hellman parameters](https://wiki.openssl.org/index.php/Diffie-Hellman_parameters) file
will also be created. You can then use those files in your Nginx configuration file:

    server {
        ...
        
        server_name           www.mysite.com
        
        ...

        ssl_certificate       PATH/TO/easy_ssl/ssl/live/mysite.com/fullchain.pem
        ssl_certificate_key   PATH/TO/easy_ssl/ssl/live/mysite.com/privkey.pem
        
        ...
        
        ssl_dh_param          PATH/TO/easy_ssl/ssl/dhparam-2048.pem
        
        ...
    }
    
To renew the certificate, include the generated `nginx.conf` file in your nginx configuration.
Note you will only be able to renew a certificate