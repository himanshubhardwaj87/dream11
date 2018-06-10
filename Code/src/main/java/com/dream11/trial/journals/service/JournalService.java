package com.dream11.trial.journals.service;

import com.dream11.trial.journals.model.Journal;
import com.dream11.trial.journals.model.Publisher;
import com.dream11.trial.journals.model.User;

import java.util.List;

public interface JournalService {

	List<Journal> listAll(User user);

	List<Journal> publisherList(Publisher publisher);

	Journal publish(Publisher publisher, Journal journal, Long categoryId);

	void unPublish(Publisher publisher, Long journalId);
}
