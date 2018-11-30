# REMEDI Infrastructure

The project contains setup and deployment code for setting up a [REMEDI](https://github.com/ivan-zapreev/Distributed-Translation-Infrastructure) Machine Translation cluster.
There are 2 separate parts of this project:

## Packer

Contains [Packer](https://www.packer.io/) configuration for creating an AMI image containing a build of REMEDI,
and a build of the [Processor](https://github.com/NationalCrimeAgency/remedi-tools) used for pre-/post- processing
text. This should be run before deploying the Terraform code, using something along the lines of:

```
/opt/bin/packer build \
    -var-file=vars.json \
    -var "aws_vpc_id=$VPC" \
    -var "aws_subnet_id=$SUBNET" \
    -var "aws_region=$AWS_DEFAULT_REGION" \
    packer.json

```

Additional variables can be set, see `packer/packer.json` for full details.

## Terraform

Contains [Terraform](https://www.terraform.io/) configuration for deploying a cluster to AWS.
The cluster will consist of:

* 1 Pre/post processing server (referred to as processor) - This server performs pre- and post-processing on the text to make it amenable to machine translation
* _n_ Translation servers (referred to as server) per language - These servers perform the actual machine translation
* 1 Load Balancer (referred to as balancer) - This server manages requests to the translation servers

There are numerous variables that need to be set prior to deploying the Terraform, see `terraform/vars.tf` for full details.

The cluster assumes that your models (per language, there should be a language model, reordering model, and translation model)
are available on an S3 bucket, using the following naming convention respectively:

* {language}_en.lm (e.g. *nl_en.lm*)
* {language}_en.rm
* {language}_en.tm

Currently, it is assumed that English will always be the target language.

If a REMEDI server configuration file (named `{language}_en.cfg`) is available in the S3 bucket
(as produced by the output of the model tuning), then values from this configuration file will be
used for the model for the following fields (i.e. the outputs of model tuning):

* de_lin_dist_penalty
* lm_feature_weights
* rm_feature_weights
* tm_feature_weights
* tm_word_penalty

Secure Web Socket (TLS) support can be enabled by passing the Terraform module the required certificates and keys.
Currently, TLS is supported only for the balancer and processor, as these are the public facing elements.
Communication between the balancer and the translation servers is not encrypted, but is contained within your VPC.
This is a restriction imposed by this Terraform configuration, and not by REMEDI. 