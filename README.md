# CheckMK-IMR Integration

This guide provides step-by-step instructions for integrating CheckMK monitoring system with IMR (IT Management Registry) to send notifications via webhook.

## Prerequisites

Before starting the integration, ensure you have:
- Access to your CheckMK instance (Docker or local installation)
- Administrative privileges in CheckMK Web UI
- An IMR webhook URL (obtained from IMR by adding a CheckMK integration)

---

## Step 1: Obtain IMR Webhook URL

1. Log into your IMR instance
2. Navigate to integrations settings
3. Add a new CheckMK integration
4. Copy the generated webhook URL (you'll need this in later steps)

---

## Step 2: Install Notification Script

Choose the installation method based on your CheckMK deployment:

### Option A: Docker Container Installation

**2.1** Access your CheckMK container:
```bash
docker exec -it <CONTAINER_ID> /bin/bash
```

**2.2** Navigate to the notifications directory:
```bash
cd /opt/omd/sites/cmk/local/share/check_mk/notifications/
```

If the directory doesn't exist, create it:
```bash
mkdir -p /opt/omd/sites/cmk/local/share/check_mk/notifications/
cd /opt/omd/sites/cmk/local/share/check_mk/notifications/
```

**2.3** Download the notification script:
```bash
curl -O https://raw.githubusercontent.com/xurrent/imr-checkmk-integration/main/notify_via_imr.sh
```

Or manually copy the `notify_via_imr.sh` file from this repository.

**2.4** Set proper permissions:
```bash
chmod +x notify_via_imr.sh
chown cmk:cmk notify_via_imr.sh
```

**2.5** Verify installation:
```bash
ls -la notify_via_imr.sh
```

You should see the file with executable permissions and correct ownership.

### Option B: Local Server Installation

**2.1** Navigate to the notifications directory:
```bash
cd ~/local/share/check_mk/notifications/
```

**2.2** Download the notification script:
```bash
curl -O https://raw.githubusercontent.com/xurrent/imr-checkmk-integration/main/notify_via_imr.sh
```

Or manually copy the `notify_via_imr.sh` file from this repository.

**2.3** Set proper permissions:
```bash
chmod +x notify_via_imr.sh
```

**2.4** Verify installation:
```bash
ls -la notify_via_imr.sh
```

**2.5** Restart CheckMK:
```bash
omd restart
```

---

## Step 3: Configure Notification Rule in CheckMK Web UI

**3.1** Access notification settings:
- Log into CheckMK Web UI
- Navigate to: **Setup → Events → Notifications**

**3.2** Create a new notification rule:
- Click the **Add rule** button

**3.3** Configure general properties:
- **Description**: Enter a meaningful name (e.g., "IMR Integration" or "Send to IMR")
- **Comment** (optional): Add any relevant notes about this integration

**3.4** Set notification method:
- Under **Notification Method**, select: **notify_via_imr.sh**
- This should appear in the dropdown if the script was installed correctly

**3.5** Configure the webhook parameter:
- Find the **Parameters** section
- Add a new parameter with:
  - **Parameter Name**: `IMR_WEBHOOK`
  - **Value**: Paste your IMR webhook URL (from Step 1)

**3.6** Configure notification conditions (optional):
- **Contact Selection**: Choose which contacts should trigger this notification
- **Host & Service Conditions**: Specify which hosts/services to monitor
- **Notification Types**: Select when to notify (Problem, Recovery, Acknowledgement, etc.)
- **Time Period**: Set when notifications should be sent

**3.7** Save and activate:
- Click **Save** at the bottom of the page
- You'll see a yellow banner: "Changes not activated"
- Click the **Activate affected** button (yellow button at the top)
- Review the changes
- Click **Activate** to apply the configuration

---

## Step 4: Test the Integration

**4.1** Trigger a test notification:
- You can manually trigger a notification from a host or service
- Or wait for a real alert to occur

**4.2** Check notification logs:

For Docker installations:
```bash
docker exec -it <CONTAINER_ID> /bin/bash
tail -50 /opt/omd/sites/cmk/var/log/notify.log
```

For local installations:
```bash
su - <SITE_NAME>
tail -50 var/log/notify.log
```

**4.3** Verify successful delivery:
- Look for "Notification sent successfully to IMR" in the logs
- Check your IMR instance to confirm the notification was received

---

## Troubleshooting

### Script Not Appearing in Notification Methods
- Verify the script is in the correct directory
- Check file permissions (must be executable)
- Ensure ownership is correct (cmk:cmk for Docker)
- Restart CheckMK: `omd restart`

### Notifications Failing
- Check the `notify.log` for error messages
- Verify the webhook URL is correct
- Test the webhook URL manually with curl:
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"test": "notification"}' \
  YOUR_WEBHOOK_URL
```

### Permission Errors
- Ensure the script has execute permissions: `chmod +x notify_via_imr.sh`
- For Docker, ensure correct ownership: `chown cmk:cmk notify_via_imr.sh`

---

## What Gets Sent to IMR

The notification script sends the following information to IMR:
- Notification type (PROBLEM, RECOVERY, ACKNOWLEDGEMENT, etc.)
- Notification source (host or service)
- Host details (name, display name, state, output)
- Service details (name, state, output) - if applicable
- Problem IDs
- Contact information
- Timestamp information

---

## Support

For issues or questions:
- Repository: https://github.com/xurrent/imr-checkmk-integration
- CheckMK Documentation: https://docs.checkmk.com/
- IMR Support: Contact your IMR administrator

---

## License

See the LICENSE file for details.
