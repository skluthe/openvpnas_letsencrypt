# openvpnas_letsencrypt
Create Certificates for your OpenVPN Access server using Let's Encrypt

#### Requirements
certbot and openvpn-as must be installed on your distro of choice. This is written for Debain 10 so please change it to match your distro.

### Create Standalone Certificates
create a certificate using certbot certonly command and follow the prompts to create your ssl certificates.
```
certbot certonly
```
### Link Certificates to OpenVPN Access Server
The following commands will use a script built into your openvpnas server to manually set the certificates.
```
/usr/local/openvpn_as/scripts/confdba -mk cs.ca_bundle –value_file=/etc/letsencrypt/live/DOMAIN.TLD/fullchain.pem > /dev/null 2>&1
/usr/local/openvpn_as/scripts/confdba -mk cs.priv_key –value_file=/etc/letsencrypt/live/DOMAIN.TLD/privkey.pem > /dev/null 2>&1
/usr/local/openvpn_as/scripts/confdba -mk cs.cert -value_file=/etc/letsencrypt/live/DOMAIN.TLD/cert.pem > /dev/null 2>&1
```
### (Optional) Redirect HTTP to HTTPS
Commands made using the guide located here: https://openvpn.net/vpn-server-resources/how-to-redirect-http-to-https/
Create a new python script in /usr/local/openvpn_as/port80redirect.py containing:
```
import SimpleHTTPServer
import SocketServer
class myHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
  def do_GET(self):
    print "Request received, sending redirect..."
    self.send_response(301)
    self.send_header('Location', 'https://vpn.yourdomain.com')
    self.end_headers()
PORT = 80
handler = SocketServer.TCPServer(("", PORT), myHandler)
print "serving at port 80"
handler.serve_forever()
```
### Create a crontab that will stop OpenVPN Access and the Python Script and generate a new cert
```
sudo nano /etc/cron.d/certbot
```
```
0 */12 * * * root test -x /usr/bin/certbot -q renew --pre-hook 'sudo systemctl stop openvpnas && kill$(pgrep -f 'python /usr/local/openvpn_as/port80redirect.py')' --post-hook 'sudo systemctl start openvpnas && /usr/bin/screen -dmS port80redirect /usr/bin/python /usr/local/openvpn_as/port80redirect.py'
```
