#include <sstream>
#include <iostream>
#include <limits>

#include "filter_reads.h"

using std::string;
using std::stringstream;
using std::stoi;

Read::Read(const string& read_entry, float f_threshold, float unmapped_thr, bool keep_unmapped_reads) :
        _f_threshold(f_threshold),
        _unmapped_thr(unmapped_thr),
        _keep_unmapped_reads(keep_unmapped_reads),
        _num_unrecognized_kmers(0) {
    parse_read_entry(read_entry);
}

void Read::parse_read_entry(const string& read_entry) {
    stringstream str_stream(read_entry);
    string word;
    str_stream >> word >> _read_name;

    while (str_stream >> word) {
        auto pos = word.find("|");
        if (pos != string::npos) {
            _forward_end_read_len = stoi(word.substr(0, pos));
            _reverse_end_read_len = stoi(word.substr(pos + 1));
            _total_read_len = _forward_end_read_len + _reverse_end_read_len;
            break;
        }
    }

    string key_value_str;
    // Consider two reads in a paired end read separately.
    for (int i = 0; i < 2; ++ i) {
        // Reset kmer map for each end of the read.
        reset_kmer_map();
        while (str_stream >> key_value_str) {
            // Reaching the end of one read in the paired end read.
            if (key_value_str == "|:|") {
                break;
            }
            parse_key_value(key_value_str);
        }

        //check_kmer_counts();

        auto score = find_score();
        //std::cerr << "Read: " << _read_name << " _f_threshold: " << _f_threshold << " , score: " << score << std::endl;
        // If one read in the paired end read is viral, the whole read is considered to be viral.
        if (score >= _f_threshold) {
            _read_label = 1;
            break;
        } else {
            _read_label = 0;
        }
    }
}

void Read::reset_kmer_map() {
    _num_kmers_per_label = {{"human", 0}, {"virus", 0}, {"root", 0}, {"unmapped", 0}};
}

float Read::find_score() {
    auto num_unmapped = _num_kmers_per_label["unmapped"];
    auto num_human = _num_kmers_per_label["human"];
    auto num_viral = _num_kmers_per_label["virus"] + _num_kmers_per_label["root"];
    //std::cerr << "num_viral: " << num_viral << " num_human: " << num_human << " num_unmapped: " << num_unmapped << std::endl;
    if (num_unmapped / (num_unmapped + num_human + num_viral + std::numeric_limits<float>::epsilon()) > _unmapped_thr) {
        _is_unmapped = true;
        return _keep_unmapped_reads ? 1 : 0;
    }
    return (num_viral / (num_viral + num_human + std::numeric_limits<float>::epsilon()));
}

void Read::parse_key_value(const string& key_value_str) {
    if (key_value_str == "|:|")
        return;
    size_t pos = key_value_str.find(":");
    if (pos == string::npos) {
        std::cerr << "Warning! key value pair not parsed correctly: " << key_value_str << std::endl;
        return;
    }

    string key = key_value_str.substr(0, pos);
    int64_t value = stoi(key_value_str.substr(pos + 1));

    string label = get_label(key);
    //std::cerr << "-" << key << "-" << label << std::endl;
    if (_num_kmers_per_label.find(label) == std::end(_num_kmers_per_label)) {
        _num_unrecognized_kmers += 1;
        //std::cerr << "unrecognized kmer label: " << label << "\n";
        return;
    }
    _num_kmers_per_label[label] += value;
}

string Read::get_label(const string& key) const {
    if (key == "9606")
            return "human";
    if (key == "0")
            return "unmapped";
    if (key == "1")
            return "root";
    if (key == "10239")
            return "virus";
    else
        return "virus";

    return key;
}

string Read::get_kmer_summary() const {
    string summary = " ";
    for (const auto &pair : _num_kmers_per_label) {
        summary += pair.first + " : " + std::to_string(pair.second) + "  ";
    }
    return summary;
}

void Read::check_kmer_counts() const {
    auto num_extracted_kmers = 0;
    for (const auto& pair: _num_kmers_per_label) {
        num_extracted_kmers += pair.second;
    }
}
