Part A — Add “break glass” invalidation procedure (CLI)
A1) Create an invalidation (single path

    aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/static/index.html"

AWS shows this exact CLI pattern.
---

aws cloudfront create-invalidation \
  --distribution-id E1RHO1DDO4JLEZ \
  --paths "/static/index.html"

---

Track invalidation status

aws cloudfront get-invalidation \
  --distribution-id EZ6HAZSEZWO73 \
  --id I9RF97LD38CZ8K0BW9W2LCTT40

---
Part B — “Correctness Proof” checklist (must submit)
B1) Before invalidation: prove object is cached

    curl -i https://chewbacca-growl.com/static/index.html | sed -n '1,30p'
    curl -i https://chewbacca-growl.com/static/index.html | sed -n '1,30p'
---

curl -i https://snailtek.click/static/index.html | sed -n '1,30p'
curl -i https://snailtek.click/static/index.html | sed -n '1,30p'

--
$ curl -i https://snailtek.click/static/index.html | sed -n '1,30p'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   215  100   215    0     0    214      0  0:00:01  0:00:01 --:--:--   214
HTTP/2 200 
content-type: text/html; charset=utf-8
content-length: 215
server: Werkzeug/3.1.6 Python/3.9.25
content-disposition: inline; filename=index.html
last-modified: Thu, 12 Mar 2026 00:21:45 GMT
date: Thu, 12 Mar 2026 01:28:38 GMT
cache-control: public, max-age=86400, immutable
etag: "1773274905.491084-215-2757692189"
x-cache: RefreshHit from cloudfront
via: 1.1 647f274d751b9fc2be24dd286277e648.cloudfront.net (CloudFront)
x-amz-cf-pop: SFO53-P3
x-amz-cf-id: hU528YlajywQF3vYAUxTiClAgj-2vA2EzglsEyxbwjJEdLJqrJ994Q==

<!DOCTYPE html>
<html>
<head><title>SnailTek Invalidation Lab2b-Be-A-Man-B</title></head>
<body>
    <h1>System Status: Online</h1>
    <p>Version: 1.0.0</p>
    <p>Proof of Invalidation Success</p>
</body>
</html>
morris@Mamba:~$ curl -i https://snailtek.click/static/index.html | sed -n '1,30p'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   215  100   215    0     0   3654      0 --:--:-- --:--:-- --:--:--  3706
HTTP/2 200 
content-type: text/html; charset=utf-8
content-length: 215
server: Werkzeug/3.1.6 Python/3.9.25
content-disposition: inline; filename=index.html
last-modified: Thu, 12 Mar 2026 00:21:45 GMT
date: Thu, 12 Mar 2026 01:28:38 GMT
cache-control: public, max-age=86400, immutable
etag: "1773274905.491084-215-2757692189"
x-cache: Hit from cloudfront
via: 1.1 51ef2d5f52dad26e2bbdf93520deaaee.cloudfront.net (CloudFront)
x-amz-cf-pop: SFO53-P3
x-amz-cf-id: 7ZwKMO5LPHa03BMbaLX0MGYqhS_2HgeSCfAF_U8elFmDZEQrW-IjBg==
age: 13

<!DOCTYPE html>
<html>
<head><title>SnailTek Invalidation Lab2b-Be-A-Man-B</title></head>
<body>
    <h1>System Status: Online</h1>
    <p>Version: 1.0.0</p>
    <p>Proof of Invalidation Success</p>
</body>
</html>
---
b1-before_invalidation.jpg
---
B2) Deploy change (simulate)
Students must update index.html content at origin (or change static file).
## 1. Changed html in user_data and performed a terraform apply. 
## 2. Waited for ec2 to stabilize and ran the curl -i https://snailtek.click/static/index.html | sed -n '1,30p'
## 3.  

---
aws cloudfront create-invalidation \
  --distribution-id E1RHO1DDO4JLEZ \
  --paths "/static/index.html"

---

Track invalidation status

aws cloudfront get-invalidation \
  --distribution-id E1RHO1DDO4JLEZ \
  --id I2DMF2HLTZU8KEUDWYZW73BJDR

---
morris@Mamba:~$ aws cloudfront get-invalidation \
  --distribution-id E1RHO1DDO4JLEZ \
  --id I2DMF2HLTZU8KEUDWYZW73BJDR
{
    "Invalidation": {
        "Id": "I2DMF2HLTZU8KEUDWYZW73BJDR",
        "Status": "Completed",
        "CreateTime": "2026-03-12T01:49:31.009000+00:00",
        "InvalidationBatch": {
            "Paths": {
                "Quantity": 1,
                "Items": [
                    "/static/index.html"
                ]
            },
            "CallerReference": "cli-1773280170-613828"
        }
    }
}
---
 curl -i https://snailtek.click/static/index.html | sed -n '1,30p'
--date: Thu, 12 Mar 2026 02:00:39 GMT
etag: "1773274905.491084-215-2757692189"
server: Werkzeug/3.1.6 Python/3.9.25
content-disposition: inline; filename=index.html
last-modified: Thu, 12 Mar 2026 00:21:45 GMT
cache-control: public, max-age=86400, immutable
x-cache: Miss from cloudfront
via: 1.1 b728afd684cc887f4e71375cc2bdd25a.cloudfront.net (CloudFront)
x-amz-cf-pop: SFO53-P3
x-amz-cf-id: mZ2E803WTuIUvzY0M_l6bbJVBVk41u-V-IIRDzDq3T_eis0fT54yPA==

<!DOCTYPE html>
<html>
<head><title>SnailTek Invalidation Lab2b-Be-A-Man-B</title></head>
<body>
    <h1>System Status: Online</h1>
    <p>Version: 1.0.0</p>
    <p>Proof of Invalidation Success</p>
</body>
</html>
morris@Mamba:~$ curl -i https://snailtek.click/static/index.html | sed -n '1,30p'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   215  100   215    0     0   2587      0 --:--:-- --:--:-- --:--:--  2621
HTTP/2 200 
content-type: text/html; charset=utf-8
content-length: 215
date: Thu, 12 Mar 2026 02:00:39 GMT
etag: "1773274905.491084-215-2757692189"
server: Werkzeug/3.1.6 Python/3.9.25
content-disposition: inline; filename=index.html
last-modified: Thu, 12 Mar 2026 00:21:45 GMT
cache-control: public, max-age=86400, immutable
x-cache: Hit from cloudfront
via: 1.1 42d6669d57da2de3a7f8b1123d510158.cloudfront.net (CloudFront)
x-amz-cf-pop: SFO53-P3
x-amz-cf-id: BMkF1XqSunFXFnX98gWNYkPYDbApsKuvvrWkZRxbTf4CL5ByqyMbQQ==
age: 23

<!DOCTYPE html>
<html>
<head><title>SnailTek Invalidation Lab2b-Be-A-Man-B</title></head>
<body>
    <h1>System Status: Online</h1>
    <p>Version: 1.0.0</p>
    <p>Proof of Invalidation Success</p>
</body>
</html>

---
Part D — Incident Scenario (graded)
Scenario: “Stale index.html after deployment”
    Symptoms:
    users keep receiving old index.html which references old hashed assets
    static asset caching works, but the HTML entrypoint is stale

Required student response:
    Confirm caching (Age, x-cache)
    Explain why versioning is preferred but why entrypoint sometimes needs invalidation
    Invalidate /static/index.html only (not /*)
    Verify new content served
    Write a short incident note (2–5 sentences)

---

During the recent deployment, users reported that they were receiving the older version of index.html. This occured because the file was cached at the CloudFront edge location with a high Age header. While versioning has been enabled for all assets (i.e /static/ and /static/html) to ensure updates, the root index.html entrypoint cannot be renamed without affecting the user's experience, necessitating a targeted invalidation. I invalidated only the /static/index.html path to minimize the 'blast radius' and verified that x-cache now shows a Miss or RefreshHit with the updated content.

---
if the only files changed in the deployment are files such as /static/app.9f3c1c7.js, there is no operational necessity to invalidate. Invalidation should be restricted to assets that are not versioned. Since versioned files are unique, the content of the specific file will not change, therefore simply updating the version, should be sufficient for content delivery. Also, once the file is versioned, CloudFront will/should treat it as a new file and update automatically via caching protocols. 
AWS also provides 1,00 free invalidations per month. Since invalidations are a limited commodity, their use should be budgeted and restricted to emergency corrections of assets.






