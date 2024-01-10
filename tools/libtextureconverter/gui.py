import tkinter as tk
from tkinter import filedialog, messagebox, ttk, font
import time
import threading

class TextureConverterGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Choose resource packs to convert")

        self.create_widgets()

    def create_widgets(self):

        # Frame for instructions
        self.instruction_frame = tk.Frame(self.root)
        self.instruction_frame.pack(fill='x', padx=10, pady=10)
        tk.Label(self.instruction_frame, text="Do you want to convert installed resource packs, or convert a single zip file?").pack(side='left', fill='x', expand=True)

        # Table-like structure using Treeview
        self.tree = ttk.Treeview(self.root, columns=('Convert', 'Description'), show='headings')
        self.tree.heading('Convert', text='Convert')
        self.tree.heading('Description', text='Description')

        # Inserting options into the table
        entries = [
            ('all', 'Find Minecraft resource packs installed in your minecraft folders and convert those automatically'),
            ('default', 'Convert the default resource pack'),
            ('other', 'Choose a file to convert manually')
        ]

        for entry in entries:
            self.tree.insert('', 'end', values=entry)



        # Button Frame
        self.button_frame = tk.Frame(self.root)
        self.button_frame.pack(fill='x', padx=10, pady=10, side='bottom')  # Ensure the buttons are at the bottom
        # Create and pack the buttons separately
        self.ok_button = tk.Button(self.button_frame, text="OK", command=self.confirm_selection)
        self.ok_button.pack(side=tk.RIGHT, padx=5)
        self.cancel_button = tk.Button(self.button_frame, text="Cancel", command=self.cancel_conversion)
        self.cancel_button.pack(side=tk.RIGHT)

        self.tree.pack(fill='both', expand=True, padx=10, pady=10)

        self.root.after(1, self.adjust_column_widths)

    def adjust_column_widths(self):
        self.root.update_idletasks()  # Update the geometry of the widgets

        # Measure and set the column widths
        convert_width = tk.font.Font().measure('Convert') + 20
        description_width = max(
            tk.font.Font().measure(self.tree.set(item, 'Description')) for item in self.tree.get_children()
        ) + 20

        # Apply the column widths
        self.tree.column('Convert', width=convert_width, anchor='center')
        self.tree.column('Description', width=description_width, anchor='w')

        # Calculate the height for each row
        row_height = tk.font.Font().metrics('linespace') + 2

        # Adjust the Treeview height
        num_items = len(self.tree.get_children())
        tree_height = (row_height * num_items) * 1.8
        self.tree.config(height=num_items)

        # Calculate the total height needed
        total_height = self.instruction_frame.winfo_height() + self.button_frame.winfo_height() + tree_height + 20

        # Calculate the total width needed
        total_width = convert_width + description_width + 20

        # Set the size of the window based on content
        self.root.geometry(f"{int(total_width)}x{int(total_height)}")

        # Prevent the window from resizing smaller than it should
        self.root.minsize(int(total_width), int(total_height))

        # Update the idle tasks to recalculate sizes, may help to remove extra space
        self.root.update_idletasks()


    def confirm_selection(self):
        self.cancel_button.config(state=tk.NORMAL)
        selected_item = self.tree.focus()
        selection = self.tree.item(selected_item)
        option = selection['values'][0]
        self.show_loading_screen(option)

    def set_min_window_size(self):
        self.root.update_idletasks()  # Update the geometry of the widgets
        self.root.minsize(self.root.winfo_width(), self.root.winfo_height())



    def show_loading_screen(self, option):
        # Display a non-blocking loading message
        self.loading_label = tk.Label(self.root, text="Converting textures, please wait...", fg="blue")
        self.loading_label.pack()

        # Start the conversion process in a separate thread
        conversion_thread = threading.Thread(target=self.perform_conversion, args=(option,), daemon=True)
        conversion_thread.start()

        # Disable the OK button while the conversion is in progress
        self.ok_button.config(state=tk.DISABLED)
        self.cancel_button.config(state=tk.NORMAL)

    def perform_conversion(self, option):
        # Example names, replace with actual texture pack names after conversion
        texture_pack_names = ["Texture Pack 1", "Texture Pack 2", "Texture Pack 3"]
        # Simulate a time-consuming process

        # Perform the selected action
        if option == 'all':
            self.convert_all()
        elif option == 'default':
            self.convert_default()
        elif option == 'other':
            self.open_folder_dialog()

        # Remove the loading message and update the conversion status
        self.loading_label.pack_forget()
        messagebox.showinfo("Conversion Complete", f"Resource Packs '{', '.join(texture_pack_names)}' converted.")

        # Re-enable the OK button after the conversion is done
        self.ok_button.config(state=tk.NORMAL)

    def convert_all(self):
        # Simulate a conversion process
        print("Converting all resource packs")
        time.sleep(2)  # Simulate some time for conversion

    def convert_default(self):
        # Simulate a conversion process
        print("Converting default resource pack")
        time.sleep(2)  # Simulate some time for conversion

    def open_folder_dialog(self):
        folder_selected = filedialog.askdirectory()
        if folder_selected:
            # Simulate a conversion process
            print(f"Folder selected for conversion: {folder_selected}")
            time.sleep(2)  # Simulate some time for conversion

    def cancel_conversion(self):
        # Placeholder for cancel action, you may need to implement actual cancellation logic
        print("Conversion cancelled by user.")
        self.loading_label.pack_forget()
        self.ok_button.config(state=tk.NORMAL)
        self.cancel_button.config(state=tk.DISABLED)

def main():
    root = tk.Tk()
    app = TextureConverterGUI(root)
    app.adjust_column_widths()
    root.mainloop()

if __name__ == "__main__":
    main()
