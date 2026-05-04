require("oltp_common")

sysbench.cmdline.options = {
    type = {"default", "Specify the type of dataset (e.g., 'movies', 'series')"}
}

-- Global variables to store SQL queries and prepared statements
sql_queries = {}
prepared_statements = {}

function debug_print(msg)
    if sysbench.opt.debug then
        print("[DEBUG]: " .. msg)
    end
end

-- Function to read SQL queries from a file
function read_queries_from_file(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open SQL file: " .. filename)
    end

    for line in file:lines() do
        if line and line ~= "" then
            table.insert(sql_queries, line)  -- Keep the '?' placeholders for prepared statements
        end
    end
    file:close()
    debug_print("Loaded " .. #sql_queries .. " SQL queries from " .. filename)
end

function read_input_from_file(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Could not open input line file: " .. filename)
    end

    local input_list = {}
    for line in file:lines() do
       table.insert(input_list, line)
    end
    file:close()

    for i = #input_list, 2, -1 do -- Shuffle data
        local j = math.random(1, i)
        input_list[i], input_list[j] = input_list[j], input_list[i]
    end

    debug_print("Loaded " .. #input_list .. " lines from " .. filename)
    return input_list
end

function thread_init()
    con = sysbench.sql.driver():connect()

    local file_type = sysbench.opt["type"] or "default"
    local input_filename = file_type .. ".txt"
    local query_filename = file_type .. ".sql"

    input_lines = read_input_from_file(input_filename)
    read_queries_from_file(query_filename)

    if #input_lines == 0 then
        error("No input data loaded in thread.")
    end

    -- Prepare all queries
    print("Preparing queries")
    for i, query in ipairs(sql_queries) do
        prepared_statements[i] = con:prepare(query)
    end

    debug_print("Thread " .. sysbench.tid .. " loaded " .. #input_lines .. " input lines")
    debug_print("Thread " .. sysbench.tid .. " prepared " .. #prepared_statements .. " SQL queries")
end

-- Sysbench event function to execute prepared statements
function event(thread_id)
    local random_index = sysbench.rand.uniform(1, #input_lines)
    local random_str = tostring(input_lines[random_index])

    for _, stmt in ipairs(prepared_statements) do
        first = stmt:bind_create(sysbench.sql.type.CHAR, 50)
        stmt:bind_param(first)
        first:set(random_str)
        local rs = stmt:execute()
    end
end

-- Sysbench thread cleanup
function thread_done()
    for _, stmt in ipairs(prepared_statements) do
        stmt:close()
    end
    con:disconnect()
end
