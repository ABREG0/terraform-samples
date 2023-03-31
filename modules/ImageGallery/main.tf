resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_shared_image_gallery" "gallery" {
  name                = var.gallery_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
}

resource "azurerm_shared_image" "image" {
  depends_on = [
    azurerm_shared_image_gallery.gallery
  ]
  name                = var.image_name
  gallery_name        = azurerm_shared_image_gallery.gallery.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region
  os_type             = "Windows" # Linux
  specialized         = false


  identifier {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
  }
}
