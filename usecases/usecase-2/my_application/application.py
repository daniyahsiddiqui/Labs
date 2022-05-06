from flask import Flask
application = Flask(__name__)


@application.route('/')
@application.route('/health/')
def health_check():
    return 'Health OK!'


@application.route('/hello/<username>')
def hello_user(username):
    return 'Hello %s!\n' % username
