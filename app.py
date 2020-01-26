import json

import mysql
from flask import Flask, render_template, request, abort, redirect, flash, url_for
from flask_login import login_required
from collections import namedtuple

from mysql_db import MySQL
import mysql.connector
import flask_login
import hashlib

app = Flask(__name__)
app.secret_key = 'asjdfbajSLDFBhjasbfd'
app.config.from_pyfile('config.py')
db = MySQL(app)
login_manager = flask_login.LoginManager()
login_manager.init_app(app)


class User(flask_login.UserMixin):
    pass


@login_manager.user_loader
def user_loader(login):
    cursor = db.db.cursor(named_tuple=True)
    cursor.execute('select id, login, full_name,role_id from users where id = %s', (login,))
    user_db = cursor.fetchone()
    if user_db:
        user = User()
        user.id = user_db.id
        user.login = user_db.login
        user.name = user_db.full_name
        user.role_id = user_db.role_id
        return user
    return None


@login_manager.unauthorized_handler
def unauthorized_handler():
    return render_template("index.html", authorization=False, login="anonimus", login_false=False)


@app.route('/', methods=['POST', 'GET'])
def hello_world():
    if request.method == 'GET':
        login: str
        if flask_login.current_user.is_anonymous:
            login = "anonymus"
        else:
            login = flask_login.current_user.login
        return render_template("index.html", authorization=not flask_login.current_user.is_anonymous, login=login)
    elif request.method == 'POST':
        username = request.form.get("username")
        password = request.form.get("password")
        password_hash = hashlib.md5(password.encode()).hexdigest()
        if username and password:
            cursor = db.db.cursor(named_tuple=True, buffered=True)
            try:
                cursor.execute(
                    "SELECT id,full_name,login,role_id FROM users WHERE `login` = '%s' and `password` = '%s'" % (
                        username, password_hash))
                user = cursor.fetchone()
            except Exception:
                cursor.close()
                return render_template("index.html", authorization=False,
                                       login="anonimus", login_false=True)
            cursor.close()
            if user is not None:
                flask_user = User()
                flask_user.id = user.id
                flask_user.login = user.login
                flask_user.name = user.full_name
                flask_user.role_id = user.role_id
                flask_login.login_user(flask_user, remember=True)

                return render_template("index.html", authorization=not flask_login.current_user.is_anonymous,
                                       login=user.login, login_false=False)
            else:
                return render_template("index.html", authorization=False,
                                       login="anonimus", login_false=True)
        else:
            return render_template("index.html", authorization=False,
                                   login="anonimus", login_false=True)


@app.route('/logout', methods=['GET'])
def logout():
    flask_login.logout_user()
    return render_template("index.html", authorization=not flask_login.current_user.is_anonymous, login="anonimus",
                           login_false=False)


@app.route('/req', methods=['GET'])
@login_required
def req():
    error = request.args.get("error")
    if error == None:
        error = False
    cursor = db.db.cursor(named_tuple=True)
    cursor.execute('SELECT * FROM request order by date DESC ')
    reqs = cursor.fetchall()
    users = dict(db.select(["id", "full_name"], "users"))
    type = dict(db.select(None, "type_request"))
    status = dict(db.select(None, "status_request"))
    veiw_req = []
    for req in reqs:
        veiw_req.append({"id": req.id,
                         "date": req.date,
                         "user": users.get(req.user_id),
                         "type": type.get(req.type_id),
                         "status": status.get(req.status_id),
                         "message": req.message,
                         "user_id": req.user_id,
                         "type_id": req.type_id,
                         "status_id": req.status_id
                         })
    return render_template("req.html", login=flask_login.current_user.login, reqs=veiw_req,
                           role_id=flask_login.current_user.role_id, error=error)


@app.route('/req/delete', methods=['POST'])
@login_required
def sub_delete():
    id = request.form.get("id")
    cursor = db.db.cursor()
    cursor.execute("DELETE FROM `request` WHERE `request`.`id` = '%s'" % id)
    cursor.close()
    return redirect("/req")


@app.route('/req/new', methods=['POST', 'GET'])
@login_required
def sub_new():
    if flask_login.current_user.role_id is not [1, 2]:
        redirect("/")
    if request.method == 'GET':
        error = request.args.get("error")
        if error == None:
            error = False
        types = db.select(None, "type_request")
        statuss = db.select(None, "status_request")
        return render_template("req_new.html", types=types, statuss=statuss, error=error,
                               user_id=flask_login.current_user.id)
    elif request.method == 'POST':
        date = request.form.get("date")
        message = request.form.get("message")
        status_id = request.form.get("status_id")
        type_id = request.form.get("type_id")
        user_id = request.form.get("user_id")
        if date and message and status_id and type_id and user_id:
            cursor = db.db.cursor(named_tuple=True)
            try:
                cursor.execute(
                    "INSERT INTO `request` (`date`, `user_id`, `type_id`, `status_id`, `message`) VALUES ('%s', '%s', '%s', '%s','%s')" % (
                        date, user_id, type_id, status_id, message))
                db.db.commit()
                cursor.close()
                return redirect("req")
            except Exception:
                return url_for("req", error=True)
        else:
            return url_for("req", error=True)


@app.route('/req/edit', methods=['POST'])
@login_required
def sub_edit():
    if flask_login.current_user.role_id is not [1, 2]:
        redirect("/")
    try:
        id = request.form.get("id")
        date = request.form.get("date")
        message = request.form.get("message")
        status_id = request.form.get("status_id")
        type_id = request.form.get("type_id")
        user_id = request.form.get("user_id")
        user = request.form.get("user")
        type = request.form.get("type")
        statuss = db.select(None, "status_request")
        types = db.select(None, "type_request")
        req = {
            'id': id,
            'date': date,
            'message': message,
            'status_id': status_id,
            'type_id': type_id,
            'older_id': id,
            'user': user,
            'type': type
        }
        return render_template("req_edit.html", req=req, types=types, statuss=statuss,
                               login=flask_login.current_user.login, user_id=user_id,
                               user_role=flask_login.current_user.role_id)
    except Exception:
        return redirect(url_for("req", error=True))


@app.route('/req/edit/submit', methods=['POST'])
@login_required
def sub_edit_submit():
    older_id = request.form.get("older_id")
    date = request.form.get("date")
    status_id = request.form.get("status_id")
    type_id = request.form.get("type_id")
    message = request.form.get("message")
    if date and older_id and status_id and type_id and message:
        cursor = db.db.cursor(named_tuple=True)
        try:
            cursor.execute(
                "UPDATE `request` SET  `date` = '%s', `status_id` = '%s',`type_id` = '%s',`message` = '%s' WHERE `request`.`id` = %s" % (
                    date, status_id, type_id, message, older_id))
            db.db.commit()
            cursor.close()
            return redirect(url_for("req"))
        except Exception:
            return redirect(url_for("req", error=True))
    else:
        return redirect(url_for("req", error=True))
