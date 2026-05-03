# Leaf

Leaf is a simple backend application in C++, designed specifically for [my memo journaling project](https://memo.jamful.top). It provides a RESTful API for managing memos, allowing users to read my personal memos/projects.

## Features
- RESTful API for memo management
- Simple and lightweight design
- Written in C++ for performance

## API Endpoints
> POST /memos - Retrieve all memos
``` JSON
// Request Body:
{
    "page_index": 0,
    "page_size": 10
}

// Response Body:
{
    "memos": [
        {
            "id": "1",
            "title": "Memo Title",
            "summary": "A brief summary of the memo content...",
            "create_date": "2024-01-01T12:00:00Z",
            "markdown_file_id": "abc123",
        },
        ...
    ],
    "current_page": 0,
    "page_size": 10,
    "total_rows": 10,
    "total_memos": 100,
    "has_next": true,
    "has_prev": false
}
```

> GET /memos/{id} - Retrieve a specific memo by ID
``` JSON
// Response Body:
{
    "id": "1",
    "title": "Memo Title",
    "summary": "A brief summary of the memo content...",
    "create_date": "2024-01-01T12:00:00Z",
    "markdown_file_id": "abc123",
}
```

> GET /memos/{id}/text - Retrieve the content of a specific memo by ID
```
<Streamed Response: The content of the memo as plain text>
```

## Prerequisites
- C++23 compatible compiler
- xmake build system

## Installation
1. Clone the repository:
   ```
   git clone https://codeberg.org/Jassjam/Leaf.git
   ```
2. Navigate to the project directory:
   ```
    cd Leaf
    ```
3. Build the application using xmake:
   ```
   xmake 
   ```
4. Run the application:
   ```
    xmake run Leaf
    ```

## License
This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue if you have any suggestions or improvements.
