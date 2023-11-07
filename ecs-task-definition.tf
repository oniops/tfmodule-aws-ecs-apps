locals {
  /*
  container_definition_template = templatefile(
    "${path.module}/templates/container-definition.json.tpl",
    {
      command                = local.command == "[]" ? "null" : local.command
      cpu                    = var.cpu == 0 ? "null" : var.cpu
      disableNetworking      = var.disableNetworking ? true : false
      dnsSearchDomains       = local.dnsSearchDomains == "[]" ? "null" : local.dnsSearchDomains
      dnsServers             = local.dnsServers == "[]" ? "null" : local.dnsServers
      dockerLabels           = local.dockerLabels == "{}" ? "null" : local.dockerLabels
      dockerSecurityOptions  = local.dockerSecurityOptions == "[]" ? "null" : local.dockerSecurityOptions
      entryPoint             = local.entryPoint == "[]" ? "null" : local.entryPoint
      environment            = local.environment == "[]" ? "null" : local.environment
      essential              = var.essential ? true : false
      extraHosts             = local.extraHosts == "[]" ? "null" : local.extraHosts
      healthCheck            = local.healthCheck == "{}" ? "null" : local.healthCheck
      hostname               = var.hostname == "" ? "null" : var.hostname
      image                  = var.image == "" ? "null" : var.image
      interactive            = var.interactive ? true : false
      links                  = local.links == "[]" ? "null" : local.links
      linuxParameters        = local.linuxParameters == "{}" ? "null" : local.linuxParameters
      logConfiguration       = local.logConfiguration == "{}" ? "null" : local.logConfiguration
      memory                 = var.memory == 0 ? "null" : var.memory
      memoryReservation      = var.memoryReservation == 0 ? "null" : var.memoryReservation
      mountPoints            = local.mountPoints == "[]" ? "null" : local.mountPoints
      name                   = var.name == "" ? "null" : var.name
      portMappings           = local.portMappings == "[]" ? "null" : local.portMappings
      privileged             = var.privileged ? true : false
      pseudoTerminal         = var.pseudoTerminal ? true : false
      readonlyRootFilesystem = var.readonlyRootFilesystem ? true : false
      repositoryCredentials  = local.repositoryCredentials == "{}" ? "null" : local.repositoryCredentials
      resourceRequirements   = local.resourceRequirements == "[]" ? "null" : local.resourceRequirements
      secrets                = local.secrets == "[]" ? "null" : local.secrets
      systemControls         = local.systemControls == "[]" ? "null" : local.systemControls
      ulimits                = local.ulimits == "[]" ? "null" : local.ulimits
      user                   = var.user == "" ? "null" : var.user
      volumesFrom            = local.volumesFrom == "[]" ? "null" : local.volumesFrom
      workingDirectory       = var.workingDirectory == "" ? "null" : var.workingDirectory
    }
  )
*/
}