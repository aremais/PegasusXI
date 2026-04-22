import mariadb


def migration_name():
    return "Add item_basic.name_jp for item load / translate map"


def check_preconditions(cur):
    return


def needs_to_run(cur):
    cur.execute("SHOW COLUMNS FROM item_basic LIKE 'name_jp'")
    if not cur.fetchone():
        return True
    return False


def migrate(cur, db):
    try:
        cur.execute("ALTER TABLE item_basic ADD COLUMN name_jp TINYTEXT NULL")
        cur.execute("UPDATE item_basic SET name_jp = '' WHERE name_jp IS NULL")
        cur.execute("ALTER TABLE item_basic MODIFY name_jp TINYTEXT NOT NULL")
        db.commit()
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))
