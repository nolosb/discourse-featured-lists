import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import ConditionalLoadingSpinner from 'discourse/components/conditional-loading-spinner';
import DButton from 'discourse/components/d-button';
import TopicList from 'discourse/components/topic-list';
import Category from 'discourse/models/category';
import i18n from 'discourse-common/helpers/i18n';

export default class FeaturedList extends Component {
  @service store;
  @service router;
  @service composer;
  @service currentUser;
  @tracked filteredTopics = null;

  <template>
    {{#if this.filteredTopics}}
      <div class='featured-lists__list-container {{@list.classname}}'>
        <div class='featured-lists__list-header'>
          <h2>{{@list.title}}</h2>
          <a href='{{@list.link}}' class='feed-link'>{{i18n
              (themePrefix 'more_link')
            }}</a>
          <DButton
            class='btn btn-default'
            {{on 'click' (if this.currentUser this.createTopic this.showLogin)}}
          >{{i18n (themePrefix 'post_button')}}</DButton>
        </div>
        <ConditionalLoadingSpinner @condition={{this.isLoading}}>
          <TopicList
            @topics={{this.filteredTopics}}
            @showPosters='true'
            class='featured-lists__list-body'
          />
        </ConditionalLoadingSpinner>
      </div>
    {{/if}}
  </template>

  constructor() {
    super(...arguments);
    this.findFilteredTopics();
  }

  @action
  async findFilteredTopics() {
    const userFilters = ['new', 'unread'];
    if (userFilters.includes(`${this.args.list.filter}`) && !this.currentUser) {
      return;
    }

    let solvedFilter;
    if (this.args.list.solved) {
      solvedFilter = this.args.list.solved === 'solved' ? 'yes' : 'no';
    }

    const topicList = await this.store.findFiltered('topicList', {
      filter: this.args.list.filter,
      params: {
        category: this.args.list.category,
        tags: this.args.list.tag,
        solved: solvedFilter,
      },
    });
    if (topicList.topics) {
      return (this.filteredTopics = topicList.topics.slice(
        0,
        this.args.list.length,
      ));
    }
  }

  @action
  createTopic() {
    this.composer.openNewTopic({
      category: Category.findById(this.args.list.category),
      tags: this.args.list.tag,
      preferDraft: 'true',
    });
  }

  @action
  showLogin() {
    this.router.replaceWith('login');
  }
}
