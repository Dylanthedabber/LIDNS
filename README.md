# LIDNS setup

*One-time setup, takes ~2 minutes and works for ~10.5 hours*

> ⚠️ **Important:**  
> Do all steps on your **home network or hotspot only.**  
> This will not work on most school Wi-Fi as the DNS is hard set.

---

## Step 1 Download the Certificate

This certificate lets your Chromebook trust the server's HTTPS connections.

[Download network-cert.crt](https://drive.google.com/uc?export=download&id=1BvE7JQq_FfD2mivcmgm7oFf-Tx7ycpqI)

---

## Step 2 Import the Certificate in Chrome

1. Open Chrome and go to:  
   `chrome://certificate-manager/localcerts/usercerts`
2. Click **Import**
3. Select the downloaded file `network-cert.crt`
4. Click **Open**

---

## Step 3 Change DNS Settings

1. Press the **Search key** (magnifying glass)
2. Type **Settings** and press Enter
3. Click **Network**
4. Click your current Wi-Fi network, then click it again
5. Scroll down and click the **Network** tab
6. Select **Custom name servers**
7. Enter `192.227.130.71` in the first box  
   Leave others as `0.0.0.0`

> 💡 You only need to do this once on your home/hotspot network.

---

## Step 4 Pre-warm the Cache

Visit the tool to preload blocked sites into your Chromebook’s cache.

[Open Prewarm Tool](https://lsrelay-config-production.s3.amazonaws.com/prewarm)

> 💡 Select categories and click **Start Prewarm**
