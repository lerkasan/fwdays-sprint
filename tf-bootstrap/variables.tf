variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}

variable "required_approving_review_count_for_main_branch" {
  description = "required approving review count for mainbranch"
  type        = number
  default     = 2
}
