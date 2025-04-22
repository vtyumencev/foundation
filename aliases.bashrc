export $(cat .env | xargs)

dev_update() {
    (
        cd "$PROJECT_LOCAL_FOLDER" || { echo "❌ Failed to cd into $PROJECT_LOCAL_FOLDER"; return 1; }

        echo "📦 Building project with yarn..."
        docker compose exec web-server bash -c "
                cd /var/www/html/web/app/themes/${PROJECT_THEME_NAME} &&
                yarn &&
                yarn run build
            " || { echo "❌ Yarn build failed"; return 1; }

        echo "📤 Uploading 'public' folder via SCP..."
        scp -r -P 222 public "$CONNECT_DEV_SERVER_SSH:/usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN/web/app/themes/$CONNECT_THEME_NAME" || {
            echo "❌ SCP upload failed"; return 1;
        }

        echo "🔌 Connecting via SSH and running remote tasks..."
        ssh "$CONNECT_DEV_SERVER_SSH" -p 222 "
            cd /usr/home/$CONNECT_DEV_SERVER_SSH_USER/public_html/$CONNECT_DEV_DOMAIN &&
            git pull origin develop &&
            php$PROJECT_PHP_VERSION_SHORT /bin/composer install &&
            cd web/app/themes/$PROJECT_THEME_NAME &&
            php$PROJECT_PHP_VERSION_SHORT /bin/composer install
        " || { echo "❌ Remote SSH commands failed"; return 1; }

        echo "✅ dev_update completed successfully!"
    )
}

update_project() {
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

build_project() {
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

dev_project() {
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
