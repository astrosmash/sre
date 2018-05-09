To build and push Docker image with the server, you need to issue the following commands while being in repo's root directory:

```
docker login
docker build --tag astrosmash/sre-challenge --file docker/Dockerfile .
docker push astrosmash/sre-challenge
```

I've already built and pushed the image to docker hub, so we can use it further: https://hub.docker.com/r/astrosmash/sre-challenge/tags/

Then you will need to fill some info into terraform.tfvars:

```
{access,secret}_key for AWS api
deployer_key is your ssh public key
```

Also change default `deployer_private_key_path` location in `variables.tf`.

To provision the server to the AWS infra, you will need the following commands:

```
terraform init - to create initial state
terraform plan - to check what's going to be created
terraform apply - to actually propagate the changes
```

This will create `t2.micro` instance with latest Ubuntu ami, configure docker host on it, and run the container with the server. Log provider for the container will be `awslogs`, so it will send its stdout into Cloudwatch. Then you can see server's output in `CloudWatch Log > Groups > docker-logs > sre-challenge`. Cloudwatch metric is also assigned as a filter to this log group, so when it discrovers 'error' pattern in the log, it will trigger an alarm.

The server listens on `INADDR_ANY`, so you can just `echo -n '[17/06/2016 12:30] Time to leave' | nc ip.add.re.ss 1234`

The only thing that doesn't work is auto-subscription of an email to the SNS topic, as described here: https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email
To receive alert emails, you need to change the topic manually: `SNS > Topics > docker_cloudwatch_notifications > Subscribe to topic > Protocol: Email, Endpoint: your@email.com`.
