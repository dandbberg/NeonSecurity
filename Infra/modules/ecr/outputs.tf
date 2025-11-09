output "repository_urls" {
  description = "Map of repository names to repository URLs"
  value = {
    for k, repo in aws_ecr_repository.repositories : k => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to repository ARNs"
  value = {
    for k, repo in aws_ecr_repository.repositories : k => repo.arn
  }
}

output "repository_names" {
  description = "List of repository names"
  value = [for repo in aws_ecr_repository.repositories : repo.name]
}

