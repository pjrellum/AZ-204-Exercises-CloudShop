#!/bin/bash
# Exercise 09a: Event Grid - Environment Variables
# Copy this file to env.sh and fill in your values

# Your unique suffix (use your initials + random numbers, e.g., "jd123")
export UNIQUE_SUFFIX="YOUR_SUFFIX"

# Azure region (use a region close to you)
export LOCATION="eastus"

# Resource group name
export RESOURCE_GROUP="rg-cloudshop-${UNIQUE_SUFFIX}"

# Derived names (don't change these)
export STORAGE_NAME="stcloudshop${UNIQUE_SUFFIX}"
export FUNC_NAME="func-cloudshop-processor-${UNIQUE_SUFFIX}"
