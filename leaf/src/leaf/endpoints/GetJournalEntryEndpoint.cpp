#include <leaf/endpoints/GetJournalEntryEndpoint.hpp>

namespace leaf
{
    static crow::json::wvalue ToResponse(const JournalEntry& entry)
    {
        return crow::json::wvalue({ { "id", entry.Id },
                                    { "title", entry.Title },
                                    { "summary", entry.Summary },
                                    { "create_date", entry.CreateDate },
                                    { "markdown_file_id", entry.MarkdownFileId } });
    }

    crow::json::wvalue GetJournalEntryEndpoint::HandleRequest(const std::string& id)
    {
        auto entry = m_JournalRepository.GetJournalEntryBy(id);
        return ToResponse(entry);
    }
}
