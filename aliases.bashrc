export $(cat .env | xargs)

dev_update() {
    (
        echo "📦 Building project with yarn..."
        docker compose exec web-server bash -c "
                cd /var/www/html/web/app/themes/${PROJECT_THEME_NAME} &&
                yarn &&
                yarn run build
            " || { echo "❌ Yarn build failed"; return 1; }

        echo "📤 Uploading 'public' folder via SCP..."
        scp -r -P 222 $PROJECT_LOCAL_FOLDER/www/web/app/themes/$PROJECT_THEME_NAME/public "$CONNECT_DEV_SERVER_SSH:/usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN/web/app/themes/$PROJECT_THEME_NAME" || {
            echo "❌ SCP upload failed"; return 1;
        }

        echo "🔌 Connecting via SSH and running remote tasks..."
        ssh "$CONNECT_DEV_SERVER_SSH" -p 222 "
            cd /usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN &&
            git pull origin $CONNECT_DEV_BRANCH &&
            php$PROJECT_PHP_VERSION_SHORT /bin/composer install &&
            cd web/app/themes/$PROJECT_THEME_NAME &&
            php$PROJECT_PHP_VERSION_SHORT /bin/composer install
        " || { echo "❌ Remote SSH commands failed"; return 1; }

        echo "✅ dev_update completed successfully!"
    )
}

# Copy database and media files from the test server
dev_pull() {
    (
        ssh $CONNECT_DEV_SERVER_SSH -p222 "mysqldump $REMOTE_DB_NAME -u $REMOTE_DB_USER --password=$REMOTE_DB_PASSWORD" > misc/dump.sql &&
             sed -i "s/${CONNECT_DEV_URL}/${PROJECT_LOCAL_URL}/g" misc/dump.sql &&
             cat misc/dump.sql | docker compose exec -T db /usr/bin/mariadb -u root --password=root root &&
             scp -r -P 222 $CONNECT_DEV_SERVER_SSH:/usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN/web/app/uploads $PROJECT_LOCAL_FOLDER/www/web/app/
    )
}

# Update dependencies in root and the theme directories
project_update() {
    (
        docker compose up -d --build &&
        docker compose exec web-server bash -c "
            cd /var/www/html &&
            composer update &&
            cd /var/www/html/web/app/themes/${PROJECT_THEME_NAME} &&
            composer update
        "
    )
}

project_build() {
    (
        docker compose up -d --build &&
        docker compose exec web-server bash -c "
            cd /var/www/html &&
            composer install &&
            cd /var/www/html/web/app/themes/${PROJECT_THEME_NAME} &&
            composer install &&
            yarn &&
            yarn run build
        "
    )
}

project_up() {
    (
        docker compose up -d &&
        docker compose exec web-server bash -c "
            cd /var/www/html &&
            composer install &&
            cd /var/www/html/web/app/themes/${PROJECT_THEME_NAME} &&
            composer install &&
            yarn &&
            yarn run dev
        "
    )
}
