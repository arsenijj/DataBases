import pyodbc
from tkinter import *
from functools import partial
from tkinter import messagebox
from tkcalendar import DateEntry
from tkinter.ttk import Treeview as Tr, Combobox

window = None
connection = None
tables_names = []
view_names = []


def welcome():

    window_authorization = Tk()

    window_authorization.title("Autorepair database authorization")
    window_authorization.geometry('700x600')

    lbl = Label(window_authorization, text="Authorization", font=("Times New Roman", 30))
    lbl.place(relx=.35, rely=.2)

    lbll = Label(window_authorization, text="Login :", font=("Times New Roman", 20))
    lbll.place(relx=.25, rely=.35)

    lblp = Label(window_authorization, text="Password :", font=("Times New Roman", 20))
    lblp.place(relx=.18, rely=.5)

    txtl = Entry(window_authorization, width=30)
    txtl.place(relx=.38, rely=.37)

    txtp = Entry(window_authorization, width=30)
    txtp.place(relx=.38, rely=.52)

    btn = Button(window_authorization, text="Enter", bg="#FFDEAD", fg="black", height=3, width=15,
                 command=partial(login, txtl, txtp, window_authorization))
    btn.place(relx=.43, rely=.6)

    window_authorization.mainloop()


def login(log, p, window_authorization):

    log = log.get()
    p = p.get()

    try:
        global connection
        global tables_names
        global view_names
        connection = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'
                                    'Server=KOMPUTATORSENI\SQLEXPRESS;'
                                    'DATABASE=Autorepair2;'
                                    'UID=' + str(log) + ';PWD=' + str(p))

        cursor = connection.cursor()
        cursor.execute('SELECT Name FROM sys.views;')
        for row in cursor:
            view_names.append(row.Name)

        cursor.execute("SELECT table_name FROM INFORMATION_SCHEMA.TABLES \
                        WHERE TABLE_TYPE ='BASE TABLE';")
        for row in cursor:
            if row.table_name != 'employees' and row.table_name != 'allservices' and row.table_name != 'serviceEquipment'\
                    and row.table_name != 'serviceSparePart' and row.table_name != 'servicesInCheque' \
                    and row.table_name != 'employeeServices':
                tables_names.append(row.table_name)


        window_authorization.destroy()
        tables_buttons(tables_names, view_names)

    except pyodbc.Error as err:
        messagebox.showinfo("Error", "Wrong username or password")


def get_attributes(table_name):
    cursor = connection.cursor()
    cursor.execute(f"SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('{table_name}')")
    return [column[0] for column in cursor.fetchall()]


def get_attributes_types(table_name):
    cursor = connection.cursor()
    cursor.execute(f"SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}' ")
    return [column_type[0] for column_type in cursor.fetchall()]


def get_rows(table_name, top_selection=100, where=''):
    cursor = connection.cursor()
    cursor.execute(f"SELECT TOP {top_selection} * FROM {table_name} {where}")
    return cursor.fetchall()


def table_visualization_frame(table_name, table_window, top_selection=100, where=''):

    table_columns = get_attributes(table_name)
    frame_table = Frame(table_window)
    frame_table.pack(side='bottom', fill='both', expand=True)

    table = Tr(frame_table, show='headings')
    table['columns'] = table_columns

    for header in table_columns:
        table.heading(header, text=header, anchor='center')
        table.column(header, anchor='center')

    for row in get_rows(table_name, top_selection, where):
        table.insert('', END, values=list(row))

    scroll_pane = Scrollbar(frame_table, command=table.yview)
    scroll_pane.pack(side=RIGHT, fill=Y)

    table.pack(expand=YES, fill=BOTH, side=LEFT)
    table.configure(yscrollcommand=scroll_pane.set)


def to_date(string):
    return int(string[6:] + string[3:5] + string[0:2])


def insert_submit(table_name, data, types):
    row = tuple(to_date(data[i].get()) if types[i] == 'date' else data[i].get()
                for i in range(len(data)))
    print(row)
    cursor = connection.cursor()
    cursor.execute(f"INSERT INTO {table_name} VALUES {row}")
    connection.commit()


def insert_entry(frame, table_columns, columns_type, start_column, start_row):
    data = []
    for i in range(len(table_columns)):

        if columns_type[i] == 'time':
            la = Label(frame, text=table_columns[i] + ' (ЧЧ:MM)', width=20, bg='#AADEAD')
        else:
            la = Label(frame, text=table_columns[i], width=20, bg='#AADEAD')
        la.grid(row=start_row+i, column=start_column, sticky='w', padx=10, pady=10)

        if columns_type[i] == 'date':
            e = DateEntry(frame, width=20, date_pattern='dd/mm/yyyy')
        else:
            e = Entry(frame, width=20, justify=RIGHT)
        e.grid(row=start_row+i, column=start_column+1, sticky='e', padx=10, pady=10)

        data.append(e)

    return data


def insert(table_name, frame, table_columns, columns_type):

    data = insert_entry(frame, table_columns, columns_type[1::], 0, 0)

    Button(frame, text='Insert values to the table', bg='#FFDEAD',
           command=partial(insert_submit, table_name, data, columns_type)).grid(row=len(table_columns),
                                                                                columnspan=2, sticky='n')


def delete_submit(table, column, value):
    value = value.get()
    column = column.get()
    cursor = connection.cursor()

    if isinstance(value, str):
        cursor.execute(f"DELETE FROM {table} WHERE {column} =" + f"'{value}'")
    else:
        cursor.execute(f"DELETE FROM {table} WHERE {column} = {value}")

    connection.commit()


def delete(table_name, frame, table_columns):

    la_column = Label(frame, text='Enter attribute', width=20, bg='#aadead')
    la_column.grid(row=0, column=2, sticky='w', padx=10, pady=10)

    column_name = Combobox(frame, values=table_columns)
    column_name.grid(row=0, column=3, sticky='e', padx=10, pady=10)

    la_column_value = Label(frame, text='Enter value\n', width=20, bg='#aadead')
    la_column_value.grid(row=1, column=2, sticky='w', padx=10, pady=10)

    column_value = Entry(frame, width=20, justify=RIGHT)
    column_value.grid(row=1, column=3, sticky='e', padx=10, pady=10)

    Button(frame, text='Delete rows by the parameter', bg='#FFDEAD',
           command=partial(delete_submit, table_name,
                           column_name, column_value)).grid(row=2, columnspan=2, column=2)


def update_submit(table, columns, columns_type, data, column, value):
    data = [i.get() for i in data]
    column = column.get()
    value = value.get()
    if not value.isdigit():
        value = "'" + value + "'"
    res = ''
    flag = False
    for i in range(len(data)):
        if data[i] == '':
            continue
        if columns_type[i] == 'date':
            data[i] = to_date(data[i])
            data[i] = str(data[i])
            flag = True
        if not data[i].isdigit() or flag:
            res += columns[i] + " = '" + data[i] + "', "
        else:
            res += columns[i] + ' = ' + data[i] + ", "

    res = res[:-2:]

    cursor = connection.cursor()
    cursor.execute(f"UPDATE {table} SET {res} WHERE {column}={value}")
    connection.commit()


def update(table_name, frame, table_columns, columns_type):

    Label(frame, text='enter attribute', width=20, bg='#AADEAD').grid(row=0, column=4, sticky='w', padx=10, pady=10)

    column_name = Combobox(frame, values=table_columns)
    column_name.grid(row=0, column=5, sticky='e', padx=10, pady=10)

    Label(frame, text='Enter value of\nattribute', width=20, bg='#AADEAD').grid(row=1, column=4,
                                                                                 sticky='w', padx=10, pady=10)

    column_value = Entry(frame, width=20, justify=RIGHT)
    column_value.grid(row=1, column=5, sticky='e', padx=10, pady=10)

    Label(frame, text='Enter values. \nIf the evaluation field is not required, leave it blank',
          bg='#FFDEAD').grid(row=2, columnspan=2, column=4)

    data = insert_entry(frame, table_columns[1::], columns_type[1::], 4, 3)

    Button(frame, text='Insert values', bg='#FFDEAD',
           command=partial(update_submit, table_name, table_columns[1::], columns_type[1::], data, column_name,
                           column_value)).grid(row=len(table_columns) + 3, columnspan=2, column=4)


def table_operations_frame(table_name, table_window):

    frame = Frame(table_window, bg='#AADEAD')
    frame.pack(side='left', fill='x', expand=False, ipady=5)
    table_columns = get_attributes(table_name)
    columns_type = get_attributes_types(table_name)

    insert(table_name, frame, table_columns[1:], columns_type)
    delete(table_name, frame, table_columns[::])
    update(table_name, frame, table_columns, columns_type)


def select_top_submit(table_name, table_window, col):
    win = Toplevel(table_window)
    table_visualization_frame(table_name, win, col.get())


def select_top(frame, table_name, table_window):
    a = Label(frame, text='Enter number of rows, \nwhich must be shown', bg='#FFDEAD')
    a.grid(row=0, column=0)

    col = Entry(frame, width=20, justify=RIGHT)
    col.grid(row=0, column=1, sticky='e', padx=10, pady=10)

    Button(frame, text='Show', bg='#AADEAD',
           command=partial(select_top_submit, table_name, table_window, col)).grid(row=0, column=2, sticky='w')


def find_by_attr_submit(table_name, table_window, column_name, value):
    win = Toplevel(table_window)
    value_unpacked = ' WHERE ' + column_name.get() + " = " + value.get()
    table_visualization_frame(table_name, win, 100, value_unpacked)


def find_by_attr(frame, table_name, table_window):

    a = Label(frame, text='Enter the attribute, on which \nstrings will be searched', bg='#FFDEAD')
    a.grid(row=1, column=0)

    table_columns = get_attributes(table_name)

    value = Entry(frame, width=20, justify=RIGHT)
    value.grid(row=2, column=1, sticky='w', padx=10, pady=10)

    column_name = Combobox(frame, values=table_columns)
    column_name.grid(row=1, column=1, sticky='w', padx=10, pady=10)

    Button(frame, text='Show', bg='#AADEAD',
           command=partial(find_by_attr_submit, table_name, table_window, column_name, value)).grid(row=3, column=1,
                                                                                                    sticky='e')


def table_view_frame(table_name, table_window):
    frame = Frame(table_window, bg='#ffdead')
    frame.pack(side='right', fill='both', expand=True, ipady=5, ipadx=5)
    select_top(frame, table_name, table_window)
    find_by_attr(frame, table_name, table_window)


def open_window_table(table_name):

    table_window = Toplevel(window)
    table_window.title(f"{table_name}")

    table_visualization_frame(table_name, table_window)
    table_operations_frame(table_name, table_window)
    table_view_frame(table_name, table_window)


def open_view(view_name):
    view_window = Toplevel(window)
    view_window.title(f'{view_name}')
    table_visualization_frame(view_name, view_window)


def tables_buttons(tables_name, view_names):
    c = 0
    j = 0
    for i in range(len(tables_name)):
        Button(window, text=(tables_name[i][0].upper() + tables_name[i][1:]),
               height=3, width=24, background='#FFDEAD', font='Courier 10',
               command=partial(open_window_table, tables_name[i])).grid(row=c, column=j, pady=5, padx=10)
        j += 1
        if j == 3:
            c += 1
            j = 0
    c += 2
    for i in range(len(view_names)):
        Button(window, text=(view_names[i][0].upper() + view_names[i][1:]),
               height=3, width=24, background='#FFDEAD', font='Courier 10',
               command=partial(open_view, view_names[i])).grid(row=c, column=j, pady=5, padx=10)
        j += 1
        if j == 3:
            c += 1
            j = 0


welcome()
print(tables_names)
#
# if tables_names:
#     window = Tk()
#     tables_buttons(tables_names)
#     window.mainloop()
