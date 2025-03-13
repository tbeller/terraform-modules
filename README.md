# Terraform Modules for Azure

This repository contains several Terraform modules for managing Azure resources. Each module is designed to be reusable and easy to integrate into Terraform configurations.

## Modules

Below is a list of available modules in this repository. Click on the module name to view its specific README and usage instructions.

- [AVD with Entra ID Authentication](modules/avd-entra-id/README.md)
- [WAN Gateway](modules/wan-gateway/README.md)

## Usage

To use a module, include it in your Terraform configuration as shown below:

```hcl
module "example" {
  source = "path/to/module"
  # module-specific variables
}
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.