#!/bin/bash
# Exercise 10: Service Bus - Environment Variables

export UNIQUE_SUFFIX="YOUR_SUFFIX"
export LOCATION="eastus"
export RESOURCE_GROUP="rg-cloudshop-${UNIQUE_SUFFIX}"

# Derived names
export SERVICEBUS_NAMESPACE="sb-cloudshop-${UNIQUE_SUFFIX}"
export QUEUE_NAME="order-processing"
export TOPIC_NAME="order-events"
