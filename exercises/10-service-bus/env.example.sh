#!/bin/bash
# Exercise 10: Service Bus - Environment Variables

export UNIQUE_SUFFIX="YOUR_SUFFIX"
export LOCATION="westeurope"
export RESOURCE_GROUP="rg-cloudshop-${UNIQUE_SUFFIX}"

# Derived names
export FUNC_NAME="func-cloudshop-${UNIQUE_SUFFIX}"
export STORAGE_NAME="stcloudshop${UNIQUE_SUFFIX}"
export SERVICEBUS_NAMESPACE="sbns-cloudshop-${UNIQUE_SUFFIX}"
export QUEUE_NAME="orders"
