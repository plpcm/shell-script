#!/bin/env python
#-*- encoding: utf8 -*-

import ConfigParser
import string, os, sys,base64
import urllib2,urllib
import smtplib 
from email.mime.text import MIMEText 
from email.header import Header

reload(sys)
sys.setdefaultencoding('utf8')

conf = os.path.realpath(sys.path[0]) + "/mail.conf"
#声明变量cf，然后读得conf文件
cf = ConfigParser.ConfigParser()
cf.read(conf)

import urllib

def my_urlencode(str) :
    reprStr = repr(str).replace(r'\x', '%')
    return reprStr[1:-1]

# 发送邮件函数 
def send_mail(cf,userkey, sub, context): 
    '''''
    to_list: 发送给谁
    sub: 主题
    context: 内容
    send_mail("xxx@126.com","sub","context")
    ''' 

    #mail to list
    mailto_list = cf.get('userlist',userkey).split(',')
    #mail type
    mail_host = cf.get("mail",'mail_host')
    mail_user = cf.get("mail",'mail_user')
    mail_postfix = cf.get("mail",'mail_postfix')
    mail_pass = cf.get("mail",'mail_pass')

    me = "sys<sys@"+mail_postfix+">" 
    mefrom = mail_user + "<"+mail_user+"@"+mail_postfix+">"

    if not isinstance(sub,unicode):
        sub = unicode(sub)
    #msg = MIMEText(context) 
    msg = MIMEText(context,format,'utf-8')
    msg["Accept-Language"]="zh-CN"
    msg["Accept-Charset"]="ISO-8859-1,utf-8"
    msg['Subject'] = sub 
    msg['From'] = me 
    msg['To'] = ";".join(mailto_list) 
    try: 
        send_smtp = smtplib.SMTP() 
        send_smtp.connect(mail_host) 
        send_smtp.login(mail_user, mail_pass) 
        send_smtp.sendmail(mefrom, mailto_list, msg.as_string()) 
        send_smtp.close() 
        return True 
    except Exception as e: 
        print(str(e)) 
        return False 

def send_weixin(url,sub,content):
    try:
        #content=content.replace('\n','')
        content=my_urlencode(content)
        sub=my_urlencode(sub)
        url=my_urlencode(url)
        http_api='http://www.xx.com/send'
        if ( url == "" ):
            urllib2.urlopen(http_api + '?content='+content+'&title='+sub)
        elif url.startswith('http') :
            #url = base64.b64encode(url)
            urllib2.urlopen(http_api + '?content='+content+'&title='+sub+'&url='+url)
        else :
            urllib2.urlopen(http_api + '?content='+content+'&title='+sub+'&type='+url)
        return True
    except:
        return False
    
#main
def send(type,userkey_url,sub,content):
    if type == "mail":
        if (True == send_mail(cf,userkey_url,sub,content)):    
            "测试成功"
        else:
            print ("测试失败")
    elif type == "weixin":
        if (True == send_weixin(userkey_url,sub,content)):    
            "测试成功"
        else:
            print ("测试失败")
    else :
        print "sorry"


if __name__ == '__main__': 
    #判断传递的变量是否够用
    if len(sys.argv) < 4 :
        print "usage:%s type userkey" %(sys.argv[0])
        sys.exit(1) 

    type = sys.argv[1]
    userkey = sys.argv[2]
    subject = sys.argv[3]
    content = sys.argv[4]

    send(type,userkey,subject,content)
