printenv | grep -v "no_proxy" >> /etc/environment

mkdir /root/.aws
printf "[default]\nregion = %s" $AWS_REGION > /root/.aws/config
printf "[default]\naws_access_key_id = %s\naws_secret_access_key = %s" $AWS_KEY_ID $AWS_SECRET_KEY > /root/.aws/credentials
chmod 600 /root/.aws/*

cron -f
