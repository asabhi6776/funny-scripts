import random
import string

def generate_password(length):
    if length < 8:
        raise ValueError("Password length must be at least 8 characters.")

    # Character sets
    lower = string.ascii_lowercase
    upper = string.ascii_uppercase
    digits = string.digits
    symbols = "!@#$%^&*()-_=+[]{}|;:,.<>?/"

    # Ensure at least one character from each set
    password = [
        random.choice(lower),
        random.choice(upper),
        random.choice(digits),
        random.choice(symbols)
    ]

    # Fill remaining characters
    all_chars = lower + upper + digits + symbols
    password += random.choices(all_chars, k=length - len(password))

    # Shuffle to make the password unpredictable
    random.shuffle(password)

    return ''.join(password)

if __name__ == "__main__":
    try:
        user_input = int(input("Enter desired password length (minimum 8): "))
        password = generate_password(user_input)
        print(f"Generated password: {password}")
    except ValueError as e:
        print(f"Error: {e}")
