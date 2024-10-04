"""
CREATE TABLE authors (
    id bigserial NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE books (
    id bigserial NOT NULL PRIMARY KEY,
    title TEXT,
    release_date DATE NOT NULL,
    price DOUBLE PRECISION DEFAULT 0 NOT NULL,
    author_id BIGINT REFERENCES authors
);

INSERT INTO authors (name) VALUES
('J.K. Rowling'),    -- 1
('George R.R. Martin'),  -- 2
('J.R.R. Tolkien'),  -- 3
('Agatha Christie'), -- 4
('Haruki Murakami'), -- 5
('Stephen King'),    -- 6
('Jane Austen'),     -- 7
('Isaac Asimov'),    -- 8
('Margaret Atwood'), -- 9
('Mark Twain');      -- 10

INSERT INTO books (title, release_date, price, author_id) VALUES
('Harry Potter and the Philosophers Stone', '1997-06-26', 39.99, 1),
('Harry Potter and the Chamber of Secrets', '1998-07-02', 34.99, 1),
('Harry Potter and the Prisoner of Azkaban', '1999-07-08', 40.99, 1),
('A Game of Thrones', '1996-08-06', 45.00, 2),
('A Clash of Kings', '1998-11-16', 47.99, 2),
('A Storm of Swords', '2000-08-08', 42.99, 2),
('The Hobbit', '1937-09-21', 30.50, 3),
('The Fellowship of the Ring', '1954-07-29', 35.00, 3),
('The Two Towers', '1954-11-11', 36.99, 3),
('The Return of the King', '1955-10-20', 39.50, 3),
('Murder on the Orient Express', '1934-01-01', 25.00, 4),
('The ABC Murders', '1936-01-06', 28.50, 4),
('And Then There Were None', '1939-11-06', 29.99, 4),
('Kafka on the Shore', '2002-09-12', 32.00, 5),
('Norwegian Wood', '1987-09-04', 31.00, 5),
('1Q84', '2009-05-29', 48.99, 5),
('The Shining', '1977-01-28', 29.99, 6),
('It', '1986-09-15', 35.99, 6),
('Pride and Prejudice', '1813-01-28', 24.99, 7),
('Sense and Sensibility', '1811-10-30', 23.50, 7),
('Foundation', '1951-06-01', 31.50, 8),
('I, Robot', '1950-12-02', 27.99, 8),
('The Handmaids Tale', '1985-08-17', 28.99, 9),
('Oryx and Crake', '2003-05-01', 34.00, 9),
('Adventures of Huckleberry Finn', '1884-12-10', 22.00, 10),
('The Adventures of Tom Sawyer', '1876-06-25', 20.50, 10);
--------------------------------
--------------------------------
-- .1 פונקציה המקבלת את שם המשתמש ומחזירה הודעת HELLO + שם המשתמש + תאריך ושעה

CREATE OR REPLACE FUNCTION greet_user(username TEXT)
RETURNS TEXT AS $$
DECLARE
    current_time TEXT;
BEGIN
    current_time := to_char(NOW(), 'YYYY-MM-DD HH24:MI:SS');
    RETURN 'HELLO ' || username || ', current date and time: ' || current_time;
END;
$$ LANGUAGE plpgsql;

SELECT greet_user('YourUsername');   -- כדי לקרוא לפונקציה

------------------------------------------------------
-- .2 פונקציה המ קבלת שני מספרים precision double ומחזירה את הסכום/כפ ל/הפרש/חלוקה שלהם

CREATE OR REPLACE FUNCTION calculate_operations(num1 DOUBLE PRECISION, num2 DOUBLE PRECISION)
RETURNS TABLE (sum_result DOUBLE PRECISION, product_result DOUBLE PRECISION, difference_result DOUBLE PRECISION, quotient_result DOUBLE PRECISION) AS $$
BEGIN
    sum_result := num1 + num2;
    product_result := num1 * num2;
    difference_result := num1 - num2;

    -- טיפול במקרה של חלוקה באפס
    IF num2 != 0 THEN
        quotient_result := num1 / num2;
    ELSE
        quotient_result := NULL; -- או תוכל להחזיר ערך אחר במקרה של חלוקה באפס
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM calculate_operations(10.5, 2.5); -- לקרוא לפונקציה ולקבל את התוצאות
---------------------------------------------------------------------------------------------

-- .3 פונקציה המ קבלת שני מספרים INTEGER ומחזירה את הקטן מבין שניהם

CREATE OR REPLACE FUNCTION get_smaller_number(num1 INTEGER, num2 INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN LEAST(num1, num2);
END;
$$ LANGUAGE plpgsql;
 -- לקרוא לפונקציה ולקבל את התוצאה
 -- להריץ את השאילתא:
 SELECT get_smaller_number(10, 5);
-----------------------------------------------------

-- .4 פונקציה המ קבלת 3 מספרים INTEGER ומחזירה את הקטן מבין שלושתם

CREATE OR REPLACE FUNCTION get_smallest_number(num1 INTEGER, num2 INTEGER, num3 INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN LEAST(num1, num2, num3);
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את התוצאה
-- להריץ את השאילתא:
SELECT get_smallest_number(10, 5, 8);
---------------------------------------------------------

-- .5 פונקציה המ קבלת מינימום ומקסימים INTEGER ומחזירה מספר אקראי ביניהם. רמז: RANDOM

CREATE OR REPLACE FUNCTION random_between(min_value INTEGER, max_value INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN FLOOR(RANDOM() * (max_value - min_value + 1)) + min_value;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל מספר אקראי בטווח המבוקש
-- להריץ את השאילתא:
SELECT random_between(1, 10);
---------------------------------------------------------

-- .6 פונקציה המחזירה סטטיסטיקות של הספר הכי זול, הכי יקר, ממוצע , וסה"כ כמות הספרים

CREATE OR REPLACE FUNCTION get_books_statistics()
RETURNS TABLE (
    cheapest_book_price DOUBLE PRECISION,
    expensive_book_price DOUBLE PRECISION,
    average_price DOUBLE PRECISION,
    total_books INTEGER
) AS $$
BEGIN
    SELECT
        MIN(price) AS cheapest_book_price,
        MAX(price) AS expensive_book_price,
        AVG(price) AS average_price,
        COUNT(*) AS total_books
    INTO cheapest_book_price, expensive_book_price, average_price, total_books
    FROM books;

    RETURN;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את הסטטיסטיקות
-- להריץ את השאילתא:
SELECT * FROM get_books_statistics();
----------------------------------------------------------

-- .7 פונקציה המחזירה את הסופר שכתב הכי הרבה ספרים וכמה ספרים כתב

CREATE OR REPLACE FUNCTION get_top_author()
RETURNS TABLE (
    author_id BIGINT,
    book_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        author_id,
        COUNT(*) AS book_count
    FROM books
    GROUP BY author_id
    ORDER BY book_count DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את הסופר שכתב הכי הרבה ספרים ואת מספר הספרים שכתב
SELECT * FROM get_top_author();
-----------------------------------------------------------------------

-- .8 פונקציה המחזירה את שם הספר הכי זול

CREATE OR REPLACE FUNCTION get_cheapest_book()
RETURNS TEXT AS $$
DECLARE
    cheapest_book_title TEXT;
BEGIN
    SELECT title INTO cheapest_book_title
    FROM books
    ORDER BY price ASC
    LIMIT 1;

    RETURN cheapest_book_title;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את שם הספר הכי זול
-- להריץ את השאילתא:
SELECT get_cheapest_book();
-----------------------------------------------

-- .9 פונקציה שסופרת כמה שורות יש בכל אחת מ2- הטבלאות ומחזירה את הסכום חלקי 2

CREATE OR REPLACE FUNCTION average_row_count()
RETURNS INTEGER AS $$
DECLARE
    count1 INTEGER;
    count2 INTEGER;
BEGIN
    -- ספירת השורות בטבלה הראשונה
    SELECT COUNT(*) INTO count1 FROM table1;

    -- ספירת השורות בטבלה השנייה
    SELECT COUNT(*) INTO count2 FROM table2;

    -- החזרת הממוצע
    RETURN (count1 + count2) / 2;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את הממוצע של מספר השורות בשתי הטבלאות
-- להריץ את השאילתא:
SELECT average_row_count();
------------------------------------------------------------

-- .10 פונקציה שעושה INSERT לספר ומחזירה את ה- ID שנוצר

CREATE OR REPLACE FUNCTION insert_book(book_title TEXT)
RETURNS BIGINT AS $$
DECLARE
    new_id BIGINT;
BEGIN
    -- ביצוע ה-INSERT והחזרת ה-ID שנוצר
    INSERT INTO books (title) VALUES (book_title) RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולהוסיף ספר חדש
SELECT insert_book('NameOfYourBook');
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-- בונוס:
-- .11 פונקציה שעושה INSERT לסופר ומחזירה את ה- ID שנוצר

CREATE OR REPLACE FUNCTION insert_author(author_name TEXT)
RETURNS BIGINT AS $$
DECLARE     -- מתחיל בלוק ההצהרות ומצהיר על משתנה בשם new_id מסוג BIGINT
    new_id BIGINT;
BEGIN
    -- ביצוע ה-INSERT והחזרת ה-ID שנוצר
    INSERT INTO authors (name) VALUES (author_name) RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולהוסיף סופר חדש
-- להריץ את השאילתא:

SELECT insert_author('NameOfYourAuthor');
------------------------------------------------------
------------------------------------------------------

-- .12 פונקציה המחזירה כמה ספרים בממוצע כתב כל סופר

CREATE OR REPLACE FUNCTION average_books_per_author()
RETURNS DOUBLE PRECISION AS $$
DECLARE
    average_books DOUBLE PRECISION;
BEGIN
    SELECT AVG(book_count) INTO average_books
    FROM (
        SELECT COUNT(*) AS book_count
        FROM books
        GROUP BY author_id
    ) AS author_book_counts;

    RETURN average_books;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את הממוצע של מספר הספרים לכל סופר
-- להריץ את השאילתא:
SELECT average_books_per_author();
-----------------------------------------------------
-----------------------------------------------------

-- .13 פרוצדורה שמעדכנת פרטי ספר, ולא מחזירה ערך. כיצד מפעילים פרוצדורה בקוד SQL?

CREATE OR REPLACE PROCEDURE update_book_details(book_id BIGINT, new_title TEXT, new_price DOUBLE PRECISION)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE books
    SET title = new_title, price = new_price
    WHERE id = book_id;
END;
$$;
-- דוגמה, אם ברצוננו לעדכן ספר עם מזהה 1 לשם חדש ומחיר חדש, צריך להריץ את השאילתא הבאה:
CALL update_book_details(1, 'Name_of_the_new_book', 29.99);
-- דוגמה להפעלת הפרוצדורה:
-------------------------------------------------------
-------------------------------------------------------

-- .14 פרוצדורה שמעדכנת פרטי ס ופר, ולא מחזירה ערך. כיצד מפעילים פרוצדורה בקוד SQL?

CREATE OR REPLACE PROCEDURE update_author_details(author_id BIGINT, new_name TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE authors
    SET name = new_name
    WHERE id = author_id;
END;
$$;
-- הפעלת הפרוצדורה
CALL update_author_details(1, 'Name_of_new_book');
--------------------------------------------------------
--------------------------------------------------------

-- .15 פונקציה המקבלת מחיר מיני מלי ומקסימלי ומחזירה את כל הספרים שהמחיר שלהם בטווח

CREATE OR REPLACE FUNCTION get_books_in_price_range(min_price DOUBLE PRECISION, max_price DOUBLE PRECISION)
RETURNS TABLE (
    book_id BIGINT,
    book_title TEXT,
    book_price DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, title, price
    FROM books
    WHERE price BETWEEN min_price AND max_price;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את כל הספרים בטווח המחירים הרצוי
-- -- מרצים את השאילתא:
SELECT * FROM get_books_in_price_range(10.00, 50.00);
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- .16 פונקציה המקבלת שמות של 2 סופרים ומחזירה את כל הספרים שנכתבו לא על ידי 2 הסופרים תוך
-- שימוש ב - WITH:
-- מצא את כל הספרים שנכתבו ע"י הסופר הראשון לתוך 1AUTH_BOOKS
-- מצא את כל הספרים שנכתבו ע"י הסופר השני לתוך 2AUTH_BOOKS
-- ואז חיפוש של כל הספרים שה- ID שלהם לא מופיע בשתי הרשימות

CREATE OR REPLACE FUNCTION get_books_excluding_authors(author_name1 TEXT, author_name2 TEXT)
RETURNS TABLE (
    book_id BIGINT,
    book_title TEXT
) AS $$
WITH
    auth_books1 AS (
        SELECT b.id, b.title
        FROM books b
        JOIN authors a ON b.author_id = a.id
        WHERE a.name = author_name1
    ),
    auth_books2 AS (
        SELECT b.id, b.title
        FROM books b
        JOIN authors a ON b.author_id = a.id
        WHERE a.name = author_name2
    )
SELECT b.id, b.title
FROM books b
WHERE b.id NOT IN (SELECT id FROM auth_books1)
  AND b.id NOT IN (SELECT id FROM auth_books2);
END;
$$ LANGUAGE plpgsql;

-- לקרוא לפונקציה ולקבל את כל הספרים שלא נכתבו על ידי שני הסופרים
SELECT * FROM get_books_excluding_authors('Author`s 1st name', 'Author`s 2nd name');
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

-- .17 כתוב פונקצית UPSERT המקבלת פרטי ספר , במידה והספר קיים )ה - TITLE ושם הסופר זהים
-- בהתאמה( היא תעדכן את שאר הפרטים, במידה ולא אז היא תוסיף את הספר. הפונקציה תחזיר את
-- ה- ID של הספר שנוצר/עודכן

CREATE OR REPLACE FUNCTION upsert_book(
    book_title TEXT,
    author_id BIGINT,
    release_date DATE,
    price DOUBLE PRECISION
)
RETURNS BIGINT AS $$
DECLARE
    book_id BIGINT;
BEGIN
    -- מנסה לעדכן את הספר אם הוא קיים
    UPDATE books
    SET release_date = release_date,
        price = price
    WHERE title = book_title AND author_id = author_id
    RETURNING id INTO book_id;

    -- אם לא נמצא ספר לעדכון, מבצע הוספה
    IF NOT FOUND THEN
        INSERT INTO books (title, author_id, release_date, price)
        VALUES (book_title, author_id, release_date, price)
        RETURNING id INTO book_id;
    END IF;

    RETURN book_id;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולהוסיף או לעדכן ספר
SELECT upsert_book('book_title', 1, '2024-01-01', 29.99);
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- .18 פונקציה המקבלת פרמטר TEXT ותחזיר תוצאת שאילתא של כל הספרים עם עמודות: ID, TITLE,
-- אם הפרמטר שנשלח שווה ל - "D "תוחזר )בנוסף( עמודת תארי ך הוצאה, אחרת שם הסופר

CREATE OR REPLACE FUNCTION get_books_with_condition(param TEXT)
RETURNS TABLE (
    book_id BIGINT,
    book_title TEXT,
    additional_info TEXT
) AS $$
BEGIN
    IF param = 'D' THEN
        RETURN QUERY
        SELECT b.id, b.title, b.release_date::TEXT AS additional_info
        FROM books b;
    ELSE
        RETURN QUERY
        SELECT b.id, b.title, a.name AS additional_info
        FROM books b
        JOIN authors a ON b.author_id = a.id;
    END IF;
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולקבל את התוצאות המתאימות,
SELECT * FROM get_books_with_condition('D'); -- D = Value, can be other value!
----------------------------------------------------------------------
----------------------------------------------------------------------

-- .19 פונקציה המקבלת פרמטר Boolean, שם של ספר TEXT ותחזיר את המחיר של הספר. אם ה-
-- Boolean שנשלח הוא true היא תחזיר את המחיר בהנחה של 50% אחרת מחיר מלא.
-- *בונוס :2 שלח כפרמטר נוסף את אחוז ההנחה. **בונוס :3 אם נשלח ה - Boolean כ false ויחד עם
-- זאת גם אחוז ההנחה שנשלח שונה מ - ,0 אז זרוק שגיאה

CREATE OR REPLACE FUNCTION get_book_price(
    apply_discount BOOLEAN,
    book_title TEXT,
    discount_percentage DOUBLE PRECISION DEFAULT 50.0
)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    book_price DOUBLE PRECISION;
BEGIN
    -- מביא את המחיר של הספר
    SELECT price INTO book_price
    FROM books
    WHERE title = book_title;

    -- אם הספר לא נמצא, זורק שגיאה
    IF book_price IS NULL THEN
        RAISE EXCEPTION 'The book "%" does not exist.', book_title;
    END IF;

    -- אם יש להחיל הנחה
    IF apply_discount THEN
        RETURN book_price * (1 - discount_percentage / 100);
    ELSE
        -- אם לא להחיל הנחה, בודק אם אחוז ההנחה שונה מ-0
        IF discount_percentage <> 0 THEN
            RAISE EXCEPTION 'Cannot apply a non-zero discount when apply_discount is false.';
        END IF;
        RETURN book_price;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- לקרוא לפונקציה ולקבל את המחיר של הספר בהתבסס על ההנחה
SELECT get_book_price(TRUE, 'book_name', 50);
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- .20 **בונוס: צור שאילתא המקבלת שם של ספר , ורצה בלולאה על כל רשימת הספרים מ 1 ועד ל ID
-- המקסימלי ובודקת בכל איטרציה אם שם הספר הוא כמו הפרמטר שנשלח, אם כן היא תשמור את
-- האינדקס שלו. בסוף הפונקציה תחזיר את האינדקס של ה - ID של הספר או 0 אם לא נמצא

CREATE OR REPLACE FUNCTION find_book_index(book_name TEXT)
RETURNS BIGINT AS $$
DECLARE
    max_id BIGINT;
    book_index BIGINT := 0;
    i BIGINT;
BEGIN
    -- מביא את ה-ID המקסימלי של הספרים
    SELECT MAX(id) INTO max_id FROM books;

    -- רץ בלולאה מ-1 עד ה-ID המקסימלי
    FOR i IN 1..max_id LOOP
        -- בודק אם שם הספר תואם
        IF EXISTS (SELECT 1 FROM books WHERE id = i AND title = book_name) THEN
            book_index := i; -- שומר את האינדקס
            EXIT; -- יוצא מהלולאה אם נמצא
        END IF;
    END LOOP;

    RETURN book_index; -- מחזיר את האינדקס או 0 אם לא נמצא
END;
$$ LANGUAGE plpgsql;
-- לקרוא לפונקציה ולמצוא את האינדקס של הספר
SELECT find_book_index('book_name');
-------------------------------------------------
-------------------------------------------------
"""
