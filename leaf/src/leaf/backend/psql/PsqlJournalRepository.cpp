#include "PsqlJournalRepository.hpp"
#include "Pagination.hpp"

namespace leaf
{
    static JournalEntry MapRowToJournalEntry(const pqxx::row& row)
    {
        return { .Id             = row["id"].as<std::string>(),
                 .Title          = row["title"].as<std::string>(),
                 .Summary        = row["summary"].as<std::string>(),
                 .CreateDate     = row["create_date"].as<std::string>(),
                 .MarkdownFileId = row["markdown_file_id"].as<std::string>() };
    }

    Page<JournalEntry> PsqlJournalRepository::GetJournalEntries(const PageQuery& query)
    {
        constexpr const char* queryString = "FROM journal_entries";

        auto txn = m_Db.NewTransaction();

        Paginator<JournalEntry> paginator(txn);

        return paginator.FetchPage(queryString, MapRowToJournalEntry, query);
    }

    JournalEntry PsqlJournalRepository::GetJournalEntryBy(const std::string& id)
    {
        constexpr const char* queryString = "SELECT * FROM journal_entries WHERE id = $1";

        auto txn = m_Db.NewTransaction();

        auto res = txn.exec(queryString, pqxx::params{ id });
        if (res.empty())
        {
            throw std::runtime_error("Journal entry not found");
        }

        return MapRowToJournalEntry(res[0]);
    }
}
