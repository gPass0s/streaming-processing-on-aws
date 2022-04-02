data "aws_region" "current_region" {}
data "aws_caller_identity" "current" {}

locals {
  AWS_REGION  = data.aws_region.current_region.name
  AWS_ACCOUNT = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role_policy" "iam_for_kinesis_policy" {
  name   = var.RESOURCE_NAME
  role   = aws_iam_role.iam_for_kinesis.id
  policy = data.aws_iam_policy_document.kinesis_role_policy.json
}

resource "aws_iam_role" "iam_for_kinesis" {
  name               = var.RESOURCE_NAME
  assume_role_policy = data.aws_iam_policy_document.kinesis_role.json
  path               = "/service-role/"
}

data "aws_iam_policy_document" "kinesis_role" {
  version = "2012-10-17"
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "kinesisanalytics.amazonaws.com"
      ]
    }
    effect = "Allow"
    sid    = ""
  }
}

data "aws_iam_policy_document" "kinesis_role_policy" {
  version = "2012-10-17"
  statement {
    sid = "ReadInputKinesis"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords"
    ]
    resources = [
      "arn:aws:kinesis:${local.AWS_REGION}:${local.AWS_ACCOUNT}:stream/${var.KDS_INPUT_RESOURCE_NAME}"
    ]
  }
  statement {
    sid = "WriteOutputKinesis"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]
    resources = [
      "arn:aws:kinesis:${local.AWS_REGION}:${local.AWS_ACCOUNT}:stream/${var.KDS_OUTPUT_RESOURCE_NAME}"
    ]
  }
  statement{
    sid= "WriteOutputFirehose"
    effect= "Allow"
    actions= [
        "firehose:DescribeDeliveryStream",
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
    ]
    resources= [
        "*"
    ]
  }
  statement{
    sid= "ReadInputFirehose"
    effect= "Allow"
    actions= [
        "firehose:DescribeDeliveryStream",
        "firehose:*"
    ]
    resources= [
        "*"
    ]
  }
  statement{
    sid= "ReadS3ReferenceData"
    effect= "Allow"
    actions= [
        "s3:GetObject"
    ]
    resources= [
        "arn:aws:s3:::baas-data-${var.ENV}-pipeline-assets/credit-online/kda-utils/mobile_enhancement_table.csv"
    ]
  }
  statement{
    sid= "ReadEncryptedInputKinesisStream"
    effect= "Allow"
    actions= [
        "kms:Decrypt"
    ]
    resources= [
        "*"
    ]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = [ "kinesis.us-east-1.amazonaws.com" ]
    }
    condition {
      test = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values = [ "*" ]
    }
  }
  statement{
    sid= "WriteEncryptedOutputKinesisStream1"
    effect= "Allow"
    actions= [
        "kms:GenerateDataKey"
    ]
    resources= [
        "*"
    ]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = [ "kinesis.us-east-1.amazonaws.com" ]
    }
    condition {
      test = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values = [ "*" ]
    }
  }
  statement{
    sid= "WriteEncryptedOutputKinesisStream2"
    effect= "Allow"
    actions= [
        "kms:GenerateDataKey"
    ]
    resources= [
        "*"
    ]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = [ "kinesis.us-east-1.amazonaws.com" ]
    }
    condition {
      test = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values = [ "*" ]
    }
  }
  statement {
    sid        = "WriteEncryptedOutputKinesisStream3"
    effect     = "Allow"
    actions    = [
      "kms:GenerateDataKey"
    ]
    resources  = [
      "*"
    ]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = [ "kinesis.us-east-1.amazonaws.com" ]
    }
    condition {
      test = "StringLike"
      variable = "kms:EncryptionContext:aws:kinesis:arn"
      values = [ "*" ]
    }
  }
  statement {
    sid= "UseLambdaFunction"
    effect= "Allow"
    actions= [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
    ]
    resources= [
        "*"
    ]
  }
}