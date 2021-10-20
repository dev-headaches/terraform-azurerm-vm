variable "enviro" {
  type        = string
  description = "define the environment ex. dev,tst,prd,stg"
}

variable "prjname" {
  type        = string
  description = "define the project name ex. prj02"
}

variable "prjnum" {
  type        = string
  description = "define the project number for TFstate file ex. 4858"
}

variable "location" {
  type        = string
  description = "location of your resource group"
}

variable "rgname" {
  type        = string
}
variable "vmsku" {
  type        = string
}
variable "kvid" {
  type        = string
}
variable "dmzsubnetID" {
  type        = string
}
variable "intsubnetID" {
  type        = string
}

/**
variable "vmPubIPid" {
  type        = string
}

variable "wrkldID" {
  type        = string
  description = "a name/tag/id for the workload being created"
}
**/