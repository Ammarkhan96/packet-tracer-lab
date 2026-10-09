#!/bin/bash

# Folder setup
mkdir -p captures logs

TARGET_DOMAIN="example.com"
PCAP_FILE="captures/trace.pcap"

echo "=================================================="
echo "🌐 Starting End-to-End Packet Trace Lab"
echo "=================================================="

# 1. DNS Resolution
echo -e "\n[1/5] Running DNS Resolution..."
dig $TARGET_DOMAIN > logs/01_dns_resolution.log
dig $TARGET_DOMAIN +trace >> logs/01_dns_resolution.log
TARGET_IP=$(dig +short $TARGET_DOMAIN | tail -n1)
echo "Resolved $TARGET_DOMAIN -> $TARGET_IP"

# 2. Check Routing
echo -e "\n[2/5] Checking Routing Path..."
ip route get $TARGET_IP > logs/02_routing.log

# 3. Check ARP / Neighbor Discovery
echo -e "\n[3/5] Checking ARP / Neighbor Cache..."
ping -c 1 $TARGET_IP > /dev/null 2>&1
ip neigh show $TARGET_IP > logs/03_arp_neighbors.log

# 4. Start Packet Capture
echo -e "\n[4/5] Starting tcpdump in background..."
tcpdump -i any host $TARGET_DOMAIN -w $PCAP_FILE > /dev/null 2>&1 &
TCPDUMP_PID=$!
sleep 2

# 5. Generate Application Traffic
echo -e "\n[5/5] Generating HTTP & HTTPS Traffic..."
curl -s -v http://$TARGET_DOMAIN > /dev/null 2>&1
curl -s -v https://$TARGET_DOMAIN > /dev/null 2>&1

sleep 2
kill -15 $TCPDUMP_PID > /dev/null 2>&1

echo -e "\n=================================================="
echo "✅ Lab Completed Successfully!"
echo "📁 PCAP Capture saved at: $PCAP_FILE"
echo "📁 Execution logs saved at: logs/"
echo "=================================================="
