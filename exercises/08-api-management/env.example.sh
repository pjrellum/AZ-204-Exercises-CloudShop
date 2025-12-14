#!/bin/bash
# =============================================================================
# CloudShop Exercise 08 - Environment Configuration
# =============================================================================
# Copy this file to env.sh and fill in your values:
#   cp env.example.sh env.sh
#   nano env.sh  # or use your preferred editor
#
# Then source it before running any scripts:
#   source env.sh
# =============================================================================

# Your unique suffix (use your initials + random number, e.g., "abc123")
export UNIQUE_SUFFIX="<your-suffix>"

# Azure configuration
export RESOURCE_GROUP="rg-cloudshop-${UNIQUE_SUFFIX}"
export LOCATION="westeurope"

# Resource names (automatically derived from suffix)
export STORAGE_ACCOUNT="stcloudshop${UNIQUE_SUFFIX}"
export FUNCTION_APP="func-cloudshop-orders-${UNIQUE_SUFFIX}"
export APIM_NAME="apim-cloudshop-${UNIQUE_SUFFIX}"

# =============================================================================
# Validation - uncomment to test your configuration
# =============================================================================
# echo "Configuration loaded:"
# echo "  UNIQUE_SUFFIX:    $UNIQUE_SUFFIX"
# echo "  RESOURCE_GROUP:   $RESOURCE_GROUP"
# echo "  LOCATION:         $LOCATION"
# echo "  STORAGE_ACCOUNT:  $STORAGE_ACCOUNT"
# echo "  FUNCTION_APP:     $FUNCTION_APP"
# echo "  APIM_NAME:        $APIM_NAME"
