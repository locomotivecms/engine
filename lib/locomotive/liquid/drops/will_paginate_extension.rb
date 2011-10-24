class WillPaginate::Collection
  def to_liquid
    {
      :collection       => self.to_a,
      :current_page     => current_page,
      :previous_page    => previous_page,
      :next_page        => next_page,
      :total_entries    => total_entries,
      :total_pages      => total_pages,
      :per_page         => per_page
    }
  end
end
