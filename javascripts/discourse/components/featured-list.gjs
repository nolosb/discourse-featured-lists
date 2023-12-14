import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
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
    <div class='featured-lists__list-container {{@list.classname}}'>
      <div class='featured-lists__list-header'>
        <h2>{{@list.title}}</h2>
        <a href='{{@list.link}}' class='feed-link'>{{i18n
            (themePrefix 'more_link')
          }}</a>
        <DButton class='btn btn-default' @action={{this.createTopic}}>{{i18n
            (themePrefix 'post_button')
          }}</DButton>
      </div>
      <ConditionalLoadingSpinner @condition={{this.isLoading}}>
        <TopicList
          @topics={{this.filteredTopics}}
          @showPosters='true'
          class='featured-lists__list-body'
        />
      </ConditionalLoadingSpinner>
    </div>
  </template>

  constructor() {
    super(...arguments);
    this.findFilteredTopics();
  }

  @action
  async findFilteredTopics() {
    const topicList = await this.store.findFiltered('topicList', {
      filter: this.args.list.filter,
      params: {
        order: 'activity',
        category: this.args.list.category,
        tags: this.args.list.tag,
        solved: this.args.list.solved,
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
    if (this.currentUser) {
      this.composer.openNewTopic({
        category: Category.findById(this.args.list.category),
        tags: this.args.list.tag,
        preferDraft: 'true',
      });
    } else {
      this.router.transitionTo('login');
    }
  }
}
