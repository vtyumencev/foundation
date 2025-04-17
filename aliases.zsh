export $(cat .env | xargs)

alias dev_update='(
                    cd $PROJECT_LOCAL_FOLDER &&
                    yarn run build &&
                    scp -r -P 222 public $CONNECT_DEV_SERVER_SSH:/usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN/web/app/themes/$CONNECT_THEME_NAME &&
                    ssh $CONNECT_DEV_SERVER_SSH -p222 "
                        cd /usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN &&
                        git pull origin develop &&
                        php$PROJECT_PHP_VERSION_SHORT /bin/composer install &&
                        cd web/app/themes/$CONNECT_THEME_NAME &&
                        php$PROJECT_PHP_VERSION_SHORT /bin/composer install
                        "
                    )'