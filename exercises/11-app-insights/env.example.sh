#!/bin/bash
# Exercise 11: Application Insights - Environment Variables

export UNIQUE_SUFFIX="YOUR_SUFFIX"
export LOCATION="eastus"
export RESOURCE_GROUP="rg-cloudshop-${UNIQUE_SUFFIX}"

# Derived names
export APPINSIGHTS_NAME="ai-cloudshop-${UNIQUE_SUFFIX}"
export FUNC_NAME="func-cloudshop-orders-${UNIQUE_SUFFIX}"
export APIM_NAME="apim-cloudshop-${UNIQUE_SUFFIX}"
