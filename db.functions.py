
############################
## כתיבת פייטון המפעיל את הקוד
############################

import psycopg2
import psycopg2.extras

connection = psycopg2.connect(
    host="localhost",
    database="postgres",
    user="admin",  # postgres
    password="admin",
    port="5432")

cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
##########

try:
    # 1. הפעלת פונקציה: upsert_book

    print("Inserting or updating a book:");
    cursor.execute("""
        SELECT upsert_book('ספר חדש', 1, '2024-01-01', 29.99);
    """);
    book_id = cursor.fetchone()[0]
    print(f"Book ID returned: {book_id}");
##################################################################

    # 2. הפעלת פונקציה: get_book_price

    print("\nGetting book price:")
    cursor.execute("""
        SELECT get_book_price(TRUE, 'ספר חדש', 50);
    """)
    discounted_price = cursor.fetchone()[0]
    print(f"Discounted price: {discounted_price}")
####################################################

    # 3. הפעלת פונקציה: find_book_index

    print("\nFinding book index:")
    cursor.execute("""
        SELECT find_book_index('ספר חדש');
    """)
    book_index = cursor.fetchone()[0]
    print(f"Book index: {book_index}");

except Exception as e:
    print(f"An error occurred: {e}");
finally:
    # סגירת הקורסור והחיבור
    cursor.close();
    connection.close();
#####################################################
##ב. כתוב לבחירתך שאילתת INSERT או UPDATE לספר והפעל אותה בפייטון )ללא שימוש ב- SP )

# פרטי הספר
book_title = 'NewTitle'
author_id = 1
release_date = '2024-01-01'
price = 39.99

try:
    # עדכון אם הספר קיים, אחרת הוספה
    cursor.execute("""
        INSERT INTO books (title, author_id, release_date, price)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (title, author_id) DO UPDATE
        SET release_date = EXCLUDED.release_date,
            price = EXCLUDED.price
        RETURNING id;
    """, (book_title, author_id, release_date, price))

    # קבלת ה-ID שנוצר או עודכן
    book_id = cursor.fetchone()[0]
    print(f"Book ID (inserted/updated): {book_id}")

    # שמירת השינויים
    connection.commit()

except Exception as e:
    print(f"An error occurred: {e}")
finally:
    # סגירת הקורסור והחיבור
    cursor.close()
    connection.close()
