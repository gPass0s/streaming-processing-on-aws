locals {
  RESOURCE_NAME = "${var.PROJECT_NAME}-${var.ENV}-${var.RESOURCE_SUFFIX}"
}

module "security" {
  source              = "./security"
  RESOURCE_NAME       = local.RESOURCE_NAME
  AWS_TAGS            = var.AWS_TAGS
}

module "package" {
  source = "./package"
  PACKAGE_SETTINGS = {
    type     = "zip"
    filename = var.LAMBDA_SETTINGS["filename"]
  }
}

module "invoker" {
  source = "./invoker"
  SETTINGS = {
    "lambda_arn" = aws_lambda_function.lambda.arn
    "type_arn"   = var.LAMBDA_INVOKE_FUNCTION["type_arn"]
    "target_arn" = var.LAMBDA_INVOKE_FUNCTION["target_arn"]
  }
}


module "event_source" {
  source = "./event-source"
  SETTINGS = {
    "event_source_arn" = var.LAMBDA_EVENT_SOURCE["event_source_arn"]
    "event_source_url" = var.LAMBDA_EVENT_SOURCE["event_source_url"]
    "protocol"         = var.LAMBDA_EVENT_SOURCE["protocol"]
    "lambda_arn"       = aws_lambda_function.lambda.arn
  }
}

resource "aws_lambda_function" "lambda" {
  function_name                  = local.RESOURCE_NAME
  description                    = var.LAMBDA_SETTINGS["description"]
  handler                        = var.LAMBDA_SETTINGS["handler"]
  runtime                        = var.LAMBDA_SETTINGS["runtime"]
  timeout                        = var.LAMBDA_SETTINGS["timeout"]
  memory_size                    = var.LAMBDA_SETTINGS["memory_size"]
  layers                         = var.LAMBDA_LAYER
  filename                       = module.package.output_path
  source_code_hash               = module.package.output_base64sha256
  role                           = module.security.role-arn
  tags                           = var.AWS_TAGS

  environment {
    variables = var.LAMBDA_ENVIRONMENT_VARIABLES
  }

}