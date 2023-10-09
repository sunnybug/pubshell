#!/bin/bash


my_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCUZuVaC48qdqGKHMzyx1PPXzwCdSFopJCqe+VbFm8FaGGZ1JzsABBxjzkfC9E84yMnhoodgC492zSHolx+509jdSByAbHIs5P/AnavRFikEmf3WEZ1vB4zxxeL/JhRIwkGaR4SsK8OVU5LVh6n2OE0+Ept7YQB5RNwXw0VHt8DJ789ygv4QU1gF5++WNDC/P0uM3ZZgb3QM3WZDVMVAhEdqsk2BAUY6b+Lhz92o33ujU6EbIcs1vYTXL3kVvwxdRCafHc4JNRnCf/2uOPWHLuf2WeJjHp8GT6EiatVOsLwNF+cFMhV8oeeSohhbv7+VkFTgCF5BXSU+cWWKyKLiIsljr4eWavlaDLCgw04YMGYqPCrv7nL5XZZ1BgntAzDFnOsP1VlQS/dGimA7Elb51duSwODpmlirZr8wzmNH/bkgnSwykf8vI4gdmOLkhKTxrAWVEcI+AO652VFl1jSQgJVV4AXcluKv9Tvd2Xhy4CIDIAAwmE+4SB91werf5AmcqM= hxsw"

echo "add my pub key...."
mkdir -p ~/.ssh/
grep -q "$my_pubkey"  ~/.ssh/authorized_keys || echo "$my_pubkey" >>  ~/.ssh/authorized_keys

my_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBxw7mFVz/0ebgWW7RcQ9oYqFUX53/tgDbojZugRcm74BRwMwI1H6MBeTe42tvOG9sKsj0MDLezFdvYdAJOG1mETU9FxPfsVB+qBpl73/HbCgJLDm1w4p1oXVyhMHrOZlafpfVAlp5G4trFWiHg3kXfhfayTGnxnCfsVrXaGwgbrYI7Wn1XV5wKFX+g0pmwySF1UpuN9AHLvOX529Fey8sEoQ8PoogHhApJE5yICyOfOd/kTHiYjiat0mMKpO05Ie7eCK9ag7eKX0C8oKSeg6qhKJpzznfCMzNM+L5zIg7atS4Q1X/lsgIO0Miavl2tVLsV8GH4M6CPr4yeBvzeEvfPQrsMOc/UX+4zxirdM90iXrhCP3G5pDgEfocOo2jJtRH1zkxC55CZpepayCM36JxiMvPDlVE+eADMrrbOoYjC1mMtRlNvmMZWMMnLhQ6a5TNWw3Uvp/DjGq6nIic7jLhvegsqHF7pxvCR+tbJy3YjkiEPAhrodNCAynfgScBsbE= hotgame_root"
echo "add all pub key...."
mkdir -p ~/.ssh/
grep -q "$my_pubkey"  ~/.ssh/authorized_keys || echo "$my_pubkey" >>  ~/.ssh/authorized_keys

chmod 700 ~/.ssh
chmod 644 ~/.ssh/*