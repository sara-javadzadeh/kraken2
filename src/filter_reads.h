#ifndef __FILTER_READS_H__
#define __FILTER_READS_H__

#include <unordered_map>

class Read {

public:
    Read(const std::string& read_entry, float f_threshold=0.32, float unmapped_thr=0.95, bool keep_unmapped_reads=false);
    Read(const Read&) = default;
    Read& operator= (const Read&) = default;
    Read& operator= (Read&& ) = default;
    ~ Read() = default;

    std::string get_read_name() const { return _read_name; }
    int32_t get_total_read_len() const { return _total_read_len; }
    std::string get_kmer_summary() const;
    bool is_viral() const { return _read_label; }
    void reset_kmer_map();

private:
    int32_t _forward_end_read_len;
    int32_t _reverse_end_read_len;
    int32_t _total_read_len;

    std::string _read_name;
    int32_t _k;
    float _f_threshold;
    float _unmapped_thr;

    bool _read_label; // 1 is viral, 0 is non_viral
    bool _is_unmapped;
    bool _keep_unmapped_reads;
    int32_t _num_unrecognized_kmers;

    std::unordered_map<std::string, int64_t> _num_kmers_per_label;

    void parse_key_value(const std::string& key_value_str);
    void parse_read_entry(const std::string& read_entry);
    std::string get_label(const std::string& key) const;
    // Return the score based on the number of kmers and lables stored in _num_kmers_per_label.
    float find_score();
    // Check if the number of kmers extracted from the read_entry is the same as the number of kmers
    // computed based on read length and k.
    void check_kmer_counts() const;
};


#endif // __FILTER_READS_H__
