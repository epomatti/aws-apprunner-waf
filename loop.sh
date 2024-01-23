# Command for testing
# bash loop.sh https://<app_id>.us-east-2.awsapprunner.com

for i in {1..10000}
do
    # "number: $i"
    curl $1
    echo $i
done
