#include <leaf/common/Result.hpp>

#include <leaf/endpoints/ListJournalEntriesEndpoint.hpp>

#include <nlohmann/json.hpp>
#include <leaf/error/FailedToParseRequest.hpp>

namespace leaf
{
    static outcome::result<PageQuery> FromRequest(const nlohmann::json& body)
    {
        PageQuery value;

        if (body.is_discarded())
        {
            return value;
        }

        auto pageIndexIt = body.find("page_index");
        auto pageSizeIt  = body.find("page_size");

        if (pageIndexIt != body.end())
        {
            if (!pageIndexIt->is_number_unsigned())
            {
                return outcome::new_error(FailedToParseRequest(
                    "Invalid page_index value. Expected an unsigned integer."));
            }
            value.PageIndex = static_cast<uint32_t>(pageIndexIt->get<uint32_t>());
        }

        if (pageSizeIt != body.end())
        {
            if (!pageSizeIt->is_number_unsigned())
            {
                return outcome::new_error(
                    FailedToParseRequest("Invalid page_size value. Expected an unsigned integer."));
            }
            value.PageSize = static_cast<uint32_t>(pageSizeIt->get<uint32_t>());
        }

        return value;
    }

    static crow::json::wvalue ToResponse(const Page<JournalEntry>& entries)
    {
        crow::json::wvalue response{
            { "current_page", entries.CurrentPage }, { "page_size", entries.PageSize },
            { "total_rows", entries.TotalRows },     { "total_pages", entries.TotalPages },
            { "has_next", entries.HasNext() },       { "has_prev", entries.HasPrev() }
        };

        crow::json::wvalue::list items;
        for (const auto& entry : entries.Items)
        {
            items.push_back({ { "id", entry.Id },
                              { "title", entry.Title },
                              { "summary", entry.Summary },
                              { "create_date", entry.CreateDate },
                              { "markdown_file_id", entry.MarkdownFileId } });
        }

        response["items"] = std::move(items);
        return response;
    }

    crow::response ListJournalEntriesEndpoint::HandleRequest(const crow::request& req)
    {
        return outcome::try_handle_all(
            [&]() -> outcome::result<crow::response>
            {
                auto body = nlohmann::json::parse(req.body, nullptr, false);
                LEAF_OUTCOME_GET(query, FromRequest(body));
                auto entry = m_JournalRepository.GetJournalEntries(query);
                return ToResponse(entry);
            },
            [](const FailedToParseRequest& error) { return crow::response(500, error.Message); },
            []
            {
                return crow::response(500,
                                      "An unexpected error occurred while processing the request.");
            });
    }
}
